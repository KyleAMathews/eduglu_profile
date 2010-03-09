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
    'description' => 'Social media glue for learners.'
  );
}
 
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
    'views', 'advanced_help',
    // Organic Groups
    'og', 'og_access', 'og_actions', 'og_views',
    // CTools
    'ctools',
    // Context
    'context', 'context_ui',
    // Features
    'features',
    // Image
    'imageapi', 'imageapi_gd', 'imagecache',
    // Token
    'token',
    // PURL
    'purl',
    // Eduglu
    'eduglu',
    // Spaces
    'spaces', 'spaces_og',
    // Other contrib
    'r4032login',
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
    'content', 'nodereference', 'text', 'optionwidgets',
    // OG_Mailing_List
    'og_mailinglist', 'mailalias',
    // Content profile
    'content_profile',
    // Core eduglu features
    'eduglue', 'eduglu_groups', 'eduglu_wiki', 'eduglu_discussion', 'eduglu_polls', 'eduglu_solr_search', 'eduglu_user_profile',
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
function eduglu_profile_task_list() {
  return array(
    'edglu-configure' => st('Eduglu configuration'),
  );
}

/**
 * Implementation of hook_profile_tasks().
 */
function eduglu_profile_tasks(&$task, $url) {
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

    // Create the admin role.
    db_query("INSERT INTO {role} (name) VALUES ('%s')", 'admin');

    // Other variables worth setting.
    variable_set('site_footer', 'Powered by <a href="http://eduglu.com">Eduglu</a>.');
    variable_set('site_frontpage', 'frontpage');

    // Clear caches.
    drupal_flush_all_caches();

    // Enable the right theme. This must be handled after drupal_flush_all_caches()
    // which rebuilds the system table based on a stale static cache,
    // blowing away our changes.
    db_query("UPDATE {system} SET status = 0 WHERE type = 'theme'");
    db_query("UPDATE {system} SET status = 1 WHERE type = 'theme' AND name = 'dewey'");
    db_query("UPDATE {blocks} SET region = '' WHERE theme = 'dewey'");
    variable_set('theme_default', 'dewey');

    // Revert key components that are overridden by others on install.
//    $revert = array(
//      'mn_core' => array('variable'),
//    );
//    features_revert($revert);

    $task = 'finished';
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