component extends="framework.zero" {
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function onApplicationStart(){
    super.onApplicationStart();

    if( len( trim( variables.config.pegdownLocation ))){
      var jl = new javaloader.javaloader( directoryList( variables.config.pegdownLocation, false, "path", "*.jar" ), false );
      var extensions = jl.create( "org.pegdown.Extensions" );
      var binExt = 0; // NONE (65535=ALL)

      // ABBREVIATIONS, ANCHORLINKS, AUTOLINKS, DEFINITIONS, FENCED_CODE_BLOCKS,
      // HARDWRAPS, QUOTES, SMARTS, SMARTYPANTS, STRIKETHROUGH, TABLES, WIKILINKS
      var enabledExts = "DEFINITIONS,FENCED_CODE_BLOCKS,SMARTYPANTS,TABLES";

      for( ext in listToArray( enabledExts )){
        binExt = bitOr( binExt, extensions[ext] );
      }

      var pegDownProcessor = jl.create( "org.pegdown.PegDownProcessor" ).init( javaCast( "int", binExt ));

      var mdDir = expandPath( "./md" );
      var htmlDir = expandPath( "./html" );

      for( mdFile in directoryList( mdDir, false, "path", "*.md" )){
        var fileName = getFileFromPath( mdFile );
        var noExtFileName = reverse( listRest( reverse( fileName ), "." ));

        fileWrite( htmlDir & "/" & lCase( noExtFileName ) & ".html", pegDownProcessor.markdownToHtml( fileRead( mdFile )), 'utf-8' );
      }
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  public void function onRequest(){
    var template = listLast( cgi.path_info, "/" );
    var title = template;
    var generatedPage = 0;

    savecontent variable="generatedPage"{
      if( len( trim( template )) and template neq "index.cfm" ){
        include "/root/html/_header.html";

        try{
          include "/root/html/#template#.html";
        } catch( Any e ){
          writeOutput( "Missing template: " & "/root/html/#htmlEditFormat( template )#.html" );
        }
      } else {
        title = "home";
        include "/root/html/_home.html";

        writeOutput( "<ul>" );

        for( var fileName in directoryList( this.root & "/md", false, "name", "*.md", "name" )){
          if( left( fileName, 1 ) eq "_" ){
            continue;
          }

          fileName = reverse( listRest( reverse( fileName ), "." ));

          writeOutput( '<li><a href="index.cfm/' & fileName & '">' & fileName & '</a></li>' );
        }

        writeOutput( "</ul>" );
      }
    }

    include "page.cfm";

    abort;
  }
}