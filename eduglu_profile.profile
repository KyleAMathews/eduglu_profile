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
 //  remove "my feed" for anonymous users + change "my groups" to "groups" which links to the groups page, 
/** figure out maintain git branches in parallel,
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
    'poll',
    'search',
    'system',
    'taxonomy',
    'update',
    'upload',
    'user',
    // Admin
    'admin',
    // Views
    'views', 'views_ui', 'advanced_help',
    // Organic Groups
    'og', 'og_access', 'og_actions', 'og_views',
    // CTools
    'ctools',
    // Context
    'context', 'context_ui',
    // Features
    'features',
    // Image
    'imageapi', 'imageapi_gd', 'imagecache', 'imagecache_profiles',
    // Token
    'token',
    // PURL
    'purl',
    // Spaces
    'spaces', 'spaces_og', 'spaces_ui', 'spaces_dashboard', 'spaces_user',
    // Other contrib
    'date', 'r4032login', 'search404', 'jquery_update', 'jquery_ui',
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
    'eduglu_core', 'eduglu_groups', 'atrium_book', 'eduglu_discussion', 'eduglu_polls', 'eduglu_members', 'eduglu_front_page', 'eduglu_about', 'eduglu_welcome',
    // Feeds
    'feeds',
    // Formats
    'codefilter', 'markdown', 'ed_readmore', 'vertical_tabs', 'better_formats',
    // Others
    'comment_upload', 'flot', 'libraries', 'querypath',
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
    $modules = _eduglu_modules();
    $files = module_rebuild_cache();
    
    // Clear caches.
    drupal_flush_all_caches();
    
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
    variable_set('install_task', 'eduglu-modules-batch');
    batch_set($batch);
    batch_process($url, $url);
  }

  // We are running a batch task for this profile so basically do nothing and return page
  if (in_array($task, array('eduglu-modules-batch', 'eduglu-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }

  if ($task == 'eduglu-configure') {
    $batch['title'] = st('Configuring @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['operations'][] = array('_eduglu_configure', array());
    $batch['finished'] = '_eduglu_configure_finished';
    variable_set('install_task', 'eduglu-configure-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }

  return $output;
}

function _eduglu_profile_batch_finished($success, $results) {
  variable_set('install_task', 'eduglu-configure');
}

function _eduglu_configure() {
  // This isn't actually necessary as there are no node_access() entries,
  // but we run it to prevent the "rebuild node access" message from being
  // shown on install.
  node_access_rebuild();

  // Create the admin role.
  db_query("INSERT INTO {role} (name) VALUES ('%s')", 'admin');

  // Create user picture directory
  $picture_path = file_create_path(variable_get('user_picture_path', 'pictures'));
  file_check_directory($picture_path, 1, 'user_picture_path');

  // Other variables worth setting.
  variable_set('site_footer', 'Powered by <a href="http://eduglu.com">Eduglu</a>.');
  variable_set('site_frontpage', 'frontpage');

  // Add menu items to secondary-links
  $dashboard = array(
    'menu_name' => 'secondary-links',
    'options' => array('purl' => 'disabled', 'attributes' => array('title' => 'dashboard')),
    'link_title' => 'dashboard',
    'link_path' => 'dashboard',
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
  menu_link_save($dashboard);
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
    'nodes' => array('story' => 1, 'poll' => 1, 'book' => 1),
    'tags' => TRUE,
    'help' => t('Enter tags related to your post.'),
  );
  taxonomy_save_vocabulary($vocab);

  // Delete profile node type created by Content Profile as we define our own
  // User profile node type.
  node_type_delete('profile');

  // Add the default profile's "Page" content type for static pages people want to add.
  $types = array(
    array(
      'type' => 'page',
      'name' => st('Page'),
      'module' => 'node',
      'description' => st("A <em>page</em> is a simple method for creating and displaying information that rarely changes, such as an \"About us\" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site's initial home page."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
  );

  foreach ($types as $type) {
    $type = (object) _node_type_set_defaults($type);
    node_type_save($type);
  }

  // Clear caches.
  drupal_flush_all_caches();

  // Enable the right theme. This must be handled after drupal_flush_all_caches()
  // which rebuilds the system table based on a stale static cache,
  // blowing away our changes.
  db_query("UPDATE {blocks} SET status = 0, region = ''"); // disable all DB blocks
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme'");
  db_query("UPDATE {system} SET status = 1 WHERE type = 'theme' AND name = 'dewey'");
  variable_set('theme_default', 'dewey');
  variable_set('admin_theme', 'rubik');

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
    'atrium_book' => array('user', 'variable'),
    'eduglu_user_profile' => array('user', 'variable'),
    'eduglu_front_page' => array('user', 'variable'),
    'eduglu_welcome' => array('user', 'variable'),
  );
  features_revert($revert);  
}

/**
 * Finished callback for the modules install batch.
 */
function _eduglu_configure_finished($success, $results) {
  variable_set('install_task', 'profile-finished');
}

/**
 * @TODO: This might be impolite/too aggressive. We should at least check that
 * other install profiles are not present to ensure we don't collide with a
 * similar form alter in their profile.
 *
 * Set Eduglu as default install profile.
 */
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'eduglu_profile';
  }
}

/**
 * Alter the install profile configuration form and provide timezone location options.
 */
function system_form_install_configure_form_alter(&$form, $form_state) {
  $form['site_information']['site_name']['#default_value'] = 'Eduglu';
  $form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  $form['admin_account']['account']['mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];

  if (function_exists('date_timezone_names') && function_exists('date_timezone_update_site')) {
    $form['server_settings']['date_default_timezone']['#access'] = FALSE;
    $form['server_settings']['#element_validate'] = array('date_timezone_update_site');
    $form['server_settings']['date_default_timezone_name'] = array(
      '#type' => 'select',
      '#title' => t('Default time zone'),
      '#default_value' => NULL,
      '#options' => date_timezone_names(FALSE, TRUE),
      '#description' => t('Select the default site time zone. If in doubt, choose the timezone that is closest to your location which has the same rules for daylight saving time.'),
      '#required' => TRUE,
    );
  }
}

