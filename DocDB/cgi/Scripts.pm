sub HelpPopupScript {
  print "<script LANGUAGE=\"JavaScript\" type=\"text/javascript\">\n";
  print "<!-- \n";

  print "function helppopupwindow(page){\n";
  print "window.open(page,\"docdbhelp\",\"width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "//-->\n";
  print "</script>\n";
}

sub HelpLink { #FIXME Don't hard-code link
  my ($helpterm) = @_;
  print " style=\"color: red\" href=\"Javascript:helppopupwindow(\'DocDBHelp?term=$helpterm\');\">";
}

1;
