#include "oxstd.h"
enum{FEND=-1,fmname=0,fmtitle,fptr,MinLev,fnotempty,FMparts}
enum{OUTLINE,PUBLISH,KEY,PUBOPTIONS}
enum{BOOK,SLIDE,SECTION,OUTTYPES}
enum{BOOKTITLE,BOOKSUB,BOOKAUTHOR,AFFILIATION,VERSION,BOOKTAG,NBOOKPARAMS}
enum{TOC,FIG,DEF,ALG,TAB,GLOSS,CODE,INSTMAT,Fsections}
enum{kblim = 14,EXERLEV=1}
mreplace(tmplt,list);
countkbs(ss);
struct document {
    static const decl partags = {"title","subtitle","author","affiliation","version","tag"};
    static const decl
			UD = "UDRAW", 			nl = "\n",
			lvtag = '*',			tocendtag = '#',			skiptag = '%',    tocsectag='!',
			srctag = '@',
            dfbeg = "<dfn ",        dfend = "</dfn>",            dfcontl = "<span>",
            dfcontr = "</span>",	lbr = "[",            		rbr = "]",
            lp = "(",            	rp = ")",            		SKIP = "%",
            OxScan = "%z",          comstart = "<!--",			comend = "-->",
            exend = "X-->",         codeend = "C-->",            extag  = "E",
            keytag = "K",			TitleHolder = "Q",
            atag = "%author%",            ttag = "%title%",            tttag = "%tag%",
			csstag = "%css%",

			figtags = {"F","D","R","A","T","C"},
            figtypes = {"Exhibit ","Definition ","Theorem ","Algorithm ","Table ","Code "},
            figprefix= {"FIG","DEF","THM","ALG","TAB",""},
			tocopen = "<div class=\"toc-content\">",
			tocclose = "</div>",
			exopen = "<details><summary>Exercises</summary><UL class=\"steps\">",
			exclose = "</UL></details>",
			keyopen = "<details class=\"key\"><summary>Instructor Tip</summary>",
			keyclose = "</details>",
            fmlast = 4,
            prefs = {"b","z","s"},
			ltypes = {"i","I","A","1","a"},
			csstypes = {"book","slide","section"},
            scales =   {"180"   ,"100",  "100"},
			navbutton = "<button class=\"navbar-toggler\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#%targ\"></button><div class=\"collapse navbar-collapse\" id=\"%targ%\"><ul class=\"navbar-nav\">",
			inext=".htm",            	  tocext=".toc",            outext=".html";

    static decl
			begun,
			mathjax,
			buildtype,
			curx,
			curp,
			sect,
            bkvals,
			puboption,
            figmarks,
            exbeg,
            dbend,
            figtag,
            exstart,
            keystart,
			slideclass="text", //default class for each section ("text" or "slide")
            bdir = "book/",	 //default build folder
            sdir = "source/", //default source folder
            TOCFILE = "book.toc",  //default table of contents file
			tocf,				//file pointer for toc
            head0= "<!DOCTYPE html><html>\n<head><meta name=\"author\" content=\"%author%\"><link href=\'http://fonts.googleapis.com/css?family=PT+Mono|Open+Sans:400italic,700italic,400,700,800,300&subset=latin,latin-ext,greek-ext,greek\' rel=\'stylesheet\' type=\'text/css\'></link>\n<link rel=\"icon\" href=\"img/book.png\" type=\"image/png\">\n",
			csstemp = "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/%css%.css\">\n",
            headtitle="<title>%title%</title></head><body>\n",
            slidetitle="<title>%title%</title></head><body>\n",
			license = "<a href=\"https://creativecommons.org/licenses/by-nc-sa/2.0/?ref=ccsearch&atype=html\">CC BY-NC-SA 2.0<img height=\"10px\" src=\"https://search.creativecommons.org/static/img/cc_icon.svg\"/><img height=\"10px\"  src=\"https://search.creativecommons.org/static/img/cc-by_icon.svg\"/><img height=\"10px\" src=\"https://search.creativecommons.org/static/img/cc-nc_icon.svg\"/><img height=\"10px\" src=\"https://search.creativecommons.org/static/img/cc-sa_icon.svg\"/></a>",
			biglicense = "<a href=\"https://creativecommons.org/licenses/by-nc-sa/2.0/?ref=ccsearch&atype=html\">CC BY-NC-SA 2.0<img height=\"30px\" src=\"https://search.creativecommons.org/static/img/cc_icon.svg\"/><img height=\"30px\"  src=\"https://search.creativecommons.org/static/img/cc-by_icon.svg\"/><img height=\"30px\" src=\"https://search.creativecommons.org/static/img/cc-nc_icon.svg\"/><img height=\"30px\" src=\"https://search.creativecommons.org/static/img/cc-sa_icon.svg\"/></a>",
            footer = "<footer><a rel=prev href=\"%prev%.html\">&larr;</a> %tttag%. &copy; %author% %year%. %affiliation%. %license% Page %page% <a href=\"%next%.html\">&rarr;</a></footer>",
			endhtml = "</body></html>",
            lev,contents,exsec, fign, fignicks,
			fm ={{"toc","Contents",0,OUTLINE,TRUE},
                 {"figlist","Figures",0,PUBLISH,FALSE},
                 {"deflist","Definitions",0,PUBLISH,FALSE},
                 {"thlist","Theorems",0,PUBLISH,FALSE},
                 {"alglist","Algorithms",0,PUBLISH,FALSE},
                 {"tablist","Tables",0,PUBLISH,FALSE},
                 {"glossary","Glossary",0,PUBLISH,FALSE},
                 {"codelist","Code",0,PUBLISH,FALSE},
                 {"imanual","Instructor Material",0,KEY,FALSE}},
			sclass="abcdefghijklmnop";

			
    static lbeg(f,nlev,tclass="");
    static lend(f,nlev=0);
    static build(sdir="",bdir="",tocfile="",puboption=PUBLISH);
    static printheader(h,title,next="");
    static findmark(line);
	static readtoc();
    }

struct section : document{
    decl index,parent,level,pref,title,dir,source,output,anch,ord,
         child,uplev,myexer,notempty,ndefn,minprintlev,mxkb,myclass,mysdir;
    make(inh=0);
    section(index=0);
    slides();
    virtual entry(f);
    virtual glossentry(line);
	codesegment(line);
    parse(line);
    printslideheader(h);
    static printfooter(h,title,prev,next);
    printslidefooter(h);
    }
struct titlepage : section {
    decl title,subtitle;
    titlepage();
    make(inh=0);
    }
struct exercises : section {
    exercises(sect);
    append(ord,fn);
    make(inh=0);
    accum(line);
    entry(f);
	eblock(href);
    decl exdoc;
    }
