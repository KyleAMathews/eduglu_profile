<?php
 
/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 *   An array with keys 'name' and 'description' describing this profile.
 */
function eduglu_profile_profile_details() {
  return array(
    'name' => 'Eduglu',
    'description' => 'Social media glue for groups of learners.'
  );
}
 //  remove "my feed" for anonymous users + change "my groups" to "groups" which links to the groups page, permissions, new front page thing, default picture, install profile not finishing, change recent activity view so it shows something intead of page not found
/** 
 * Return an array of the modules to be enabled when this profile is installed.
 *
 * @return
 *  An array of modules to be enabled.
 */
function eduglu_profile_profile_modules() {
  return array(
     // Drupal core
    'block',
    'comment',
    'dblog',
    'filter',
    'help',
    'menu',
    'node',
    'openid',
    'search',
    'system',
    'taxonomy',
    'upload',
    'user',
    // Admin menu
    'admin_menu',
    // Views
    'views', 'views_ui', 'advanced_help',
    // Organic Groups
    'og', 'og_access', 'og_actions', 'og_views',
    // CTools
    'ctools',
    // Context
    'context', 'context_contrib', 'context_ui',
    // Features
    'features',
    // Image
    'imageapi', 'imageapi_gd', 'imagecache', 'imagecache_profiles',
    // Token
    'token',
    // PURL
    'purl',
    // Spaces
    'spaces', 'spaces_og',
    // Other contrib
    'r4032login', 'jquery_update',
  );
}

/**
 * Returns an array list of eduglu features (and supporting) modules.
 */
function _eduglu_modules() {
  return array(
    // Strongarm
    'strongarm',
    // CCK
    'content', 'nodereference', 'text', 'optionwidgets', 'link',
    // OG_Mailing_List
    'og_mailinglist', 'mailalias',
    // Content profile
    'content_profile',
    // Core eduglu features
    'eduglu_core', 'eduglu_groups', 'eduglu_wiki', 'eduglu_discussion', 'eduglu_polls', 'eduglu_members', 'eduglu_front_page',
    // Feeds
    'feeds',
    // Formats
    'codefilter', 'markdown',
    // Others
    'comment_upload',
  );
} 
/**
 * Implementation of hook_profile_task_list().
 */
function eduglu_profile_profile_task_list() {
  return array(
    'eduglu-configure' => st('Eduglu configuration'),
  );
}

/**
 * Implementation of hook_profile_tasks().
 */
function eduglu_profile_profile_tasks(&$task, $url) {
  global $install_locale;

  // Just in case some of the future tasks adds some output
  $output = '';

  if ($task == 'profile') {
    // Create a default vocabulary for storing geo terms imported by the feed_term content type
    // and subsequently used by the extractor module. Used by the mn_core feature.
    $data = array('name' => 'Locations', 'relations' => 1);
    taxonomy_save_vocabulary($data);
    variable_set('mn_core_location_vocab', $data['vid']);
    variable_set('geotaxonomy_'. $data['vid'], 1);

    // Create a vocabulary for channel tags.
    $data = array('name' => 'Channel tags', 'required' => 1, 'relations' => 0, 'tags' => 1, 'nodes' => array('channel' => 1), 'help' => 'Articles with these tags will appear in this channel.');
    taxonomy_save_vocabulary($data);
    variable_set('mn_core_tags_vocab', $data['vid']);

    $modules = _eduglu_modules();
    $files = module_rebuild_cache();
    $operations = array();
    foreach ($modules as $module) {
      $operations[] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }
    $batch = array(
      'operations' => $operations,
      'finished' => '_eduglu_profile_batch_finished',
      'title' => st('Installing @drupal', array('@drupal' => drupal_install_profile_name())),
      'error_message' => st('The installation has encountered an error.'),
    );
    // Start a batch, switch to 'profile-install-batch' task. We need to
    // set the variable here, because batch_process() redirects.
    variable_set('install_task', 'profile-install-batch');
    batch_set($batch);
    batch_process($url, $url);
  }

  if ($task == 'eduglu-configure') {
    // This isn't actually necessary as there are no node_access() entries,
    // but we run it to prevent the "rebuild node access" message from being
    // shown on install.
    node_access_rebuild();

    // Create the admin role.
    db_query("INSERT INTO {role} (name) VALUES ('%s')", 'admin');

    // Other variables worth setting.
    variable_set('site_footer', 'Powered by <a href="http://eduglu.com">Eduglu</a>.');
    variable_set('site_frontpage', 'frontpage');

    // Add menu items to secondary-links
    $my_feed = array(
      'menu_name' => 'secondary-links',
      'options' => array('purl' => 'disabled', 'attributes' => array('title' => 'my feed')),
      'link_title' => 'my feed',
      'link_path' => '<front>',
      'module' => 'eduglu_core',
      'customized' => 1,
      'plid' => 0,
      'weight' => 0,
      'expanded' => 0,
    );
    $my_groups = array(
      'menu_name' => 'secondary-links',
      'options' => array('purl' => 'disabled', 'attributes' => array('title' => 'my groups')),
      'link_title' => 'my groups',
      'link_path' => 'og/my',
      'module' => 'eduglu_core',
      'customized' => 1,
      'plid' => 0,
      'weight' => 0,
      'expanded' => 0,
    );
    menu_link_save($my_feed);
    menu_link_save($my_groups);

    // Add freetagging vocabulary
    $vocab = array(
      'name' => 'Keywords',
      'multiple' => 0,
      'required' => 0,
      'hierarchy' => 0,
      'relations' => 0,
      'module' => 'event',
      'weight' => 0,
      'nodes' => array('story' => 1, 'poll' => 1, 'wiki' => 1),
      'tags' => TRUE,
      'help' => t('Enter tags related to your post.'),
    );
    taxonomy_save_vocabulary($vocab);

    // Delete profile node type created by Content Profile as we define our own
    // User profile node type.
    node_type_delete('profile');

    // Clear caches.
    drupal_flush_all_caches();

    // Enable the right theme. This must be handled after drupal_flush_all_caches()
    // which rebuilds the system table based on a stale static cache,
    // blowing away our changes.
    db_query("UPDATE {system} SET status = 0 WHERE type = 'theme'");
    db_query("UPDATE {system} SET status = 1 WHERE type = 'theme' AND name = 'dewey'");
    db_query("UPDATE {blocks} SET region = '' WHERE theme = 'dewey'");
    variable_set('theme_default', 'dewey');

    // In Aegir install processes, we need to init strongarm manually as a
    // separate page load isn't available to do this for us.
    if (function_exists('strongarm_init')) {
      strongarm_init();
    }

    // Revert key components that are overridden by others on install.
    // Note that this comes after all other processes have run, as some cache
    // clears/rebuilds actually set variables or other settings that would count
    // as overrides. See `og_node_type()`.
    $revert = array(
      'eduglu_core' => array('variable'),
      'eduglu_groups' => array('user', 'variable'),
      'eduglu_discussions' => array('user', 'variable'),
      'eduglu_polls' => array('user', 'variable'),
      'eduglu_wiki' => array('user', 'variable'),
      'eduglu_user_profile' => array('user', 'variable'),
      'eduglu_front_page' => array('user', 'variable'),
    );
    features_revert($revert);

    // Tell installer we're finished.
    variable_set('install_task', 'profile-finished');
  }

  return $output;
}

/**
 * Finished callback for the modules install batch.
 *
 * Advance installer task to language import.
 */
function _eduglu_profile_batch_finished($success, $results) {
  variable_set('install_task', 'eduglu-configure');
}