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
    'description' => 'Social media glue for education.'
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
    'context', 'context_ui', 'context_layouts',
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
* Implementation of hook_profile_tasks().
*/
function eduglu_profile_profile_tasks() {
 
  // Install the core required modules and our extra modules
  $core_required = array('block', 'filter', 'node', 'system', 'user');
  install_include(array_merge(eduglu_profile_profile_modules(), $core_required));
 
  // Enable default theme
  install_default_theme("dewey");
  
  // Enable default admin theme
  //install_admin_theme('rubik');
}
