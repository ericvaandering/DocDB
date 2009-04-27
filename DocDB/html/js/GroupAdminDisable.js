// All disabler scripts adapted from CellarTracker (cellartracker.com)

function disabler_groups() {
  if (document.groups.admaction[0].checked == true) {
    document.groups.admin.disabled       = false;
    document.groups.view.disabled        = false;
    document.groups.create.disabled      = false;
    document.groups.remove.disabled      = false;
    document.groups.parent.disabled      = true;
    document.groups.name.disabled        = false;
    document.groups.child.disabled       = false;
    document.groups.removesubs.disabled  = true;
    document.groups.description.disabled = false;
  }
  if (document.groups.admaction[1].checked == true) {
    document.groups.admin.disabled       = true;
    document.groups.view.disabled        = true;
    document.groups.create.disabled      = true;
    document.groups.remove.disabled      = true;
    document.groups.parent.disabled      = false;
    document.groups.name.disabled        = true;
    document.groups.child.disabled       = true;
    document.groups.removesubs.disabled  = true;
    document.groups.description.disabled = true;
  }
  if (document.groups.admaction[2].checked == true) {
    document.groups.admin.disabled       = false;
    document.groups.view.disabled        = false;
    document.groups.create.disabled      = false;
    document.groups.remove.disabled      = false;
    document.groups.parent.disabled      = false;
    document.groups.name.disabled        = false;
    document.groups.child.disabled       = false;
    document.groups.removesubs.disabled  = false;
    document.groups.description.disabled = false;
  }
}
