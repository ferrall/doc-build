#include "oxstd.h"
enum{FEND=-1,fmname=0,fmtitle,fptr,FMparts}
enum{TOC,FIG,DEF,ALG,TAB,GLOSS,Fsections}
enum{PUBLISH,OUTLINE,PUBOPTIONS}
mreplace(tmplt,list);
struct document {
    static const decl 	lvtag = "*",
            dfbeg = "<dfn ",
            dfend = "</dfn>",
            dfcontl = "<span>",
            dfcontr = "</span>",
			lbr = "[",
            rbr = "]",
            lp = "(",
            rp = ")",
            SKIP = "%",
            exstart = "<!--E",
            exend = "X-->",
            atag = "%author%",
            ttag = "%title%",
            figmarks = {"<!--F","<!--D","<!--A","<!--T"},
            figtypes = {"Exhibit ","Definition ","Algorithm ","Table "},
            figprefix= {"FIG","DEF","ALG","TAB"},
            fmlast = 4,
            figtag = "<!--F-->",
            spref = "zz",
            ltypes = {"i","I","A","1","a"},
			inext=".htm",
            tocext=".toc",
            outext=".html";
    static decl
            bdir = "book/",
            sdir = "source/",
            head0= "<!DOCTYPE html><html>\n<head><meta name=\"author\" content=\"%author%\"><link             href=\'http://fonts.googleapis.com/css?family=PT+Mono|Open+Sans:400italic,700italic,400,700,800,300&subset=latin,latin-ext,greek-ext,greek\' rel=\'stylesheet\' type=\'text/css\'></link>\n<link rel=\"icon\" href=\"img/452.png\" type=\"image/png\">\n<link rel=\"stylesheet\" type=\"text/css\" href=\"css/doc.css\"></link>",
            /* <link rel=\"stylesheet\" type=\"text/css\" href=\"C:/Users/Chris/Documents/OFFICE/software/pubcss/dist/css/pubcss-acm-sig.css\"></link>\n", */
            mathjax="<script type=\"text/x-mathjax-config\"> MathJax.Hub.Config({tex2jax: {inlineMath: [[\"$\",\"$\"],[\"\\\\(\",\"\\\\)\"]], processEscapes: true}, TeX: {Macros: {RR: \"{\\\\bf R}\",bold: [\"{\\\\bf #1}\",1]}, equationNumbers: {autoNumber:\"all\" }}});</script>\n<script type=\"text/javascript\" src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML\">\n</script>",
            headtitle="<title>%title%</title></head><body>\n",
            footer = "<footer><table width=\"100%\"><tr><td width=\"20px\"><a href=\"s%prev%.html\">&larr;</a></td><td style=\"text-align:center\">&copy; %author% %year%.  %affiliation%.</td><td width=\"20px\"><a href=\"s%next%.html\">&rarr;</a></td></tr></table></footer></body></html>",
            TOCFILE = "book.toc",
            booktitle = "Title",
            bookauthor = "Author",
            affiliation = "Queen's University",
            version = "1.0",
            lev,contents,exsec, fign, fm, fignicks;
    static lbeg(f,nlev,tclass="");
    static lend(f);
    static build(sdir="",bdir="",tocfile="",puboption=PUBLISH);
    static printheader(h,title);
    }

struct section : document{
    decl index,parent,level,pref,title,dir,source,output,anch,ord,
         child,uplev,myexer,notempty,ndefn;
    make(inh=0,puboption=PUBLISH);
    section(index=0);
    slides();
    virtual entry(f);
    virtual glossentry(line);
    parse(line);
    }
struct titlepage : section {
    decl title,subtitle,made;
    titlepage(tocf);
    make(inh=0,puboption=PUBLISH);
    }
struct exercises : section {
    exercises(sect);
    append(ord,fn);
    make(inh=0,puboption=PUBLISH);
    accum(line);
    entry(f);
    decl exdoc;
    }
