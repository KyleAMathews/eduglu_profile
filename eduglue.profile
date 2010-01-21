<?php
 
/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 *   An array with keys 'name' and 'description' describing this profile.
 */
function eduglue_profile_details() {
  return array(
    'name' => 'Eduglue',
    'description' => 'Social media glue for education.'
  );
}
 
/**
 * Return an array of the modules to be enabled when this profile is installed.
 *
 * @return
 *  An array of modules to be enabled.
 */
function eduglue_profile_modules() {
  return array(
    /* optional core */
    /* other contrib */ 
    'install_profile_api', 'admin_menu', 'advanced_help', 'apachesolr', 'apachesolr_nodeaccess', 'apachesolr_og', 'apachesolr_search', 'apachesolr_stats',
    'backup_migrate', 'block', 'blog', 'book', 'cacherouter', 'comment', 'comment_upload', 'contact', 'content', 'content_copy', 'content_permissions',
    'content_profile', 'content_taxonomy', 'content_taxonomy_autocomplet', 'content_taxonomy_options', 'context', 'context_contrib', 'context_ui',
    'devel_node_access', 'diff', 'eduglue', 'eduglue_book', 'eduglue_discussion', 'eduglue_front_page', 'eduglue_job_board', 'eduglue_polls', 'eduglue_solr_search',
    'eduglue_user_profile', 'edully_front_page', 'edully_group_block', 'fasttoggle', 'features', 'fieldgroup', 'filefield', 'filter', 'freelinking', 'help',
    'jquery_update', 'link', 'mailalias', 'mailnode', 'markdown', 'masquerade', 'menu', 'modr8', 'node', 'nodereference', 'number', 'og', 'og_access', 'og_actions',
    'og_views', 'optionwidgets', 'path', 'pathauto', 'ping', 'poll', 'prepopulate', 'purl', 'r4032login', 'realname', 'registration_form', 'rules', 'search', 'spaces',
    'spaces_og', 'syslog', 'system', 'taxonomy', 'text', 'token', 'tracker', 'trigger', 'update', 'upload', 'user', 'userreference', 'views', 'views_ui'
  );
}
 
/**
* Implementation of hook_profile_tasks().
*/
function eduglue_profile_tasks() {
 
  // Install the core required modules and our extra modules
  $core_required = array('block', 'filter', 'node', 'system', 'user');
  install_include(array_merge(eduglue_profile_modules(), $core_required));
 
  // Enable default theme
  install_default_theme("dewey");
  
  // Enable default admin theme
  install_admin_theme('rubik');
}