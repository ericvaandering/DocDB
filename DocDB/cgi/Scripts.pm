sub HelpPopupScript {
  print "<script LANGUAGE=\"JavaScript\">\n";

  print "function helppopupwindow(page){\n";
  print "window.open(page,\"docdbhelp\",\"width=450,height=350,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=0,toolbar=0,left=0,top=0\");\n";
  print "}\n";

  print "</script>\n";
}

sub HelpLink {
  my ($helpterm) = @_;
  print " href=\"Javascript:helppopupwindow(\'DocDBHelp?term=$helpterm\');\">";
}

1;
