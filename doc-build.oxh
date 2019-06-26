#include "oxstd.h"
enum{FEND=-1,fmname=0,fmtitle,fptr,MinLev,FMparts}
enum{OUTLINE,PUBLISH,KEY,PUBOPTIONS}
enum{BOOKTITLE,BOOKSUB,BOOKAUTHOR,AFFILIATION,VERSION,BOOKTAG,NBOOKPARAMS}
mreplace(tmplt,list);
countkbs(ss);
struct document {
    static const decl partags = {"title","subtitle","author","affiliation","version","tag"};
    static const decl
			lvtag = '*',
			tocendtag = '#',
			skiptag = '%',
            dfbeg = "<dfn ",
            dfend = "</dfn>",
            dfcontl = "<span>",
            dfcontr = "</span>",
			lbr = "[",
            rbr = "]",
            lp = "(",
            rp = ")",
            SKIP = "%",
            OxScan = "%z",
            comstart = "<!--",
			comend = "-->", 
            exend = "X-->",
            codeend = "C-->",
            extag  = "E",
            keytag = "K",
			TitleHolder = "Q",
//            exstart = "<!--E",
//            exend = "X-->",
            atag = "%author%",
            ttag = "%title%",
            tttag = "%tag%",
            figtags = {"F","D","R","A","T","C"},
            figtypes = {"Exhibit ","Definition ","Theorem ","Algorithm ","Table ","Code "},
            figprefix= {"FIG","DEF","THM","ALG","TAB",""},
			tocopen = "<details class=\"toc\"><summary>Sections</summary>",
			tocclose = "</details>",
			exopen = "<details><summary>Exercises</summary><UL class=\"steps\">",
			exclose = "</UL></details>",
			keyopen = "<details class=\"key\"><summary>Instructor Tip</summary>",
			keyclose = "</details>",
            fmlast = 4,
            spref = "zz",
            ltypes = {"i","I","A","1","a"},
			inext=".htm",
            tocext=".toc",
            outext=".html";

    static decl
            bkvals,
			puboption,
            figmarks,
            exbeg,
            dbend,
            figtag,
            exstart,
            keystart,
            bdir = "book/",	 //default build folder
            sdir = "source/", //default source folder
            TOCFILE = "book.toc",  //default table of contents file
			tocf,				//file pointer for toc
            head0= "<!DOCTYPE html><html>\n<head><meta name=\"author\" content=\"%author%\"><link href=\'http://fonts.googleapis.com/css?family=PT+Mono|Open+Sans:400italic,700italic,400,700,800,300&subset=latin,latin-ext,greek-ext,greek\' rel=\'stylesheet\' type=\'text/css\'></link>\n<link rel=\"icon\" href=\"img/452.png\" type=\"image/png\">\n<link rel=\"stylesheet\" type=\"text/css\" href=\"css/doc.css\"></link>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"css/screen.css\"></link>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"css/print.css\"></link>",
            /* <link rel=\"stylesheet\" type=\"text/css\" href=\"C:/Users/Chris/Documents/OFFICE/software/pubcss/dist/css/pubcss-acm-sig.css\"></link>\n", */
//            mathjax="<script type=\"text/x-mathjax-config\"> MathJax.Hub.Config({tex2jax: {inlineMath: [[\"$\",\"$\"],[\"\\\\(\",\"\\\\)\"]], processEscapes: true}, TeX: {Macros: {RR: \"{\\\\bf R}\",bold: [\"{\\\\bf #1}\",1]}, equationNumbers: {autoNumber:\"all\" }}});</script>\n<script type=\"text/javascript\" src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS_CHTML\">\n</script>",		//-MML_HTMLorMML
            headtitle="<title>%title%</title></head><body>\n",
            slidetitle="<title>%title%</title></head><body>\n",
			license = "<a href=\"https://creativecommons.org/licenses/by-nc-sa/2.0/?ref=ccsearch&atype=html\">CC BY-NC-SA 2.0<img height=\"30px\" src=\"https://search.creativecommons.org/static/img/cc_icon.svg\"/><img height=\"30px\"  src=\"https://search.creativecommons.org/static/img/cc-by_icon.svg\"/><img height=\"30px\" src=\"https://search.creativecommons.org/static/img/cc-nc_icon.svg\"/><img height=\"30px\" src=\"https://search.creativecommons.org/static/img/cc-sa_icon.svg\"/></a>",
            footer = "<footer><table width=\"100%\"><tr><td width=\"20px\"><a rel=prev href=\"s%prev%.html\">&larr;</a></td><td style=\"text-align:center\">%tttag%. &copy; %author% %year%. %affiliation%. <!--%license%--></td><td width=\"20px\"><a href=\"s%next%.html\">&rarr;</a></td></tr></table></footer></body></html>",
            lev,contents,exsec, fign, fignicks,
			fm ={{"toc","Table of Contents",0,OUTLINE},
                 {"figlist","List of Figures",0,PUBLISH},
                 {"deflist","List of Definitions",0,PUBLISH},
                 {"thlist","List of Theorems",0,PUBLISH},
                 {"alglist","List of Algorithms",0,PUBLISH},
                 {"tablist","List of Tables",0,PUBLISH},
                 {"glossary","Glossary of Defined Terms &amp; Special Symbols",0,PUBLISH},
                 {"codelist","List of Code Files",0,PUBLISH},
                 {"imanual","Instructor Material",0,KEY}},
			sclass="abcdefghijk";
			enum{TOC,FIG,DEF,ALG,TAB,GLOSS,CODE,INSTMAT,Fsections}	
    static lbeg(f,nlev,tclass="");
    static lend(f,nlev=0);
    static build(sdir="",bdir="",tocfile="",puboption=PUBLISH);
    static printheader(h,title,next="");
    static printslideheader(h,title,next="");
    static printfooter(h,title,prev,next);
    static printslidefooter(h,title,prev,next);
    static findmark(line);
    }

struct section : document{
    decl index,parent,level,pref,title,dir,source,output,anch,ord,
         child,uplev,myexer,notempty,ndefn,minprintlev,mxkb;
    make(inh=0);
    section(index=0);
    slides();
    virtual entry(f);
    virtual glossentry(line);
	codesegment(h,line);
    parse(line);
    }
struct titlepage : section {
    decl title,subtitle,made;
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
