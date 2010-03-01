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
    /* optional core */
    /* other contrib */ 
    'install_profile_api', 'admin_menu', 'advanced_help',
    'backup_migrate', 'block', 'blog', 'book', 'cacherouter', 'comment', 'comment_upload', 'contact', 'content', 'content_copy', 'content_permissions',
    'content_profile', 'content_taxonomy', 'content_taxonomy_autocomplete', 'content_taxonomy_options', 'context', 'context_contrib', 'context_ui',
    'diff', 'fasttoggle', 'features', 'filefield', 'filter', 'help', 'jquery_update', 'link', 'mailalias', 'mailnode', 'markdown', 'masquerade', 'menu', 'modr8', 'node', 'nodereference', 'number', 'og', 'og_access', 'og_actions', ctools, 
    'og_views', 'optionwidgets', 'path', 'pathauto', 'ping', 'poll', 'purl', 'r4032login', 'realname', 'rules', 'search', 'spaces',
    'spaces_og', 'syslog', 'system', 'taxonomy', 'text', 'token', 'tracker', 'trigger', 'update', 'upload', 'user', 'userreference', 'views', 'views_ui'
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
