#include "doc-build.oxh"

mreplace(tmplt,list) {
    decl txt = tmplt, r;
    foreach(r in list) txt = replace(txt,r[0],r[1]);
    return txt;
    }

document::lbeg(f,nlev,tclass) {
    fprintln(f,"<OL type=\"",ltypes[nlev],"\" class=\"toc",sprint(nlev),"\">");
    }
document::lend(f) { fprintln(f,"</OL>"); }
document::printheader(h,title) {
        fprintln(h,mreplace(head0,{{atag,bookauthor},{"<br/>",": "}}));
        fprintln(h,mathjax);
        fprintln(h,mreplace(headtitle,{{ttag,title},{"<br/>",": "}}));
        }

titlepage::titlepage(tocf) {
    section(0);
    fscan(tocf,"%z",&booktitle,"%z",&subtitle,"%z",&bookauthor,"%z",&affiliation,"%z",&version);
    title = booktitle;
    pref = "";
    source = "title";
    output = source;
    made = FALSE;
    ord = 1;
    parent=-1;
    }

titlepage::make(inh) {
    if (isfile(inh)) {
        decl s,fp,line,inbody,nn;
        fprintln(inh,"<div class=\"tp\" style=\"background:url(img/titlepage.png) no-repeat  bottom center; background-size:70%;\" ><h1>",booktitle,"</h1><hr/>",subtitle,"<br/>&nbsp;<br/>&nbsp;<br/><h3>",bookauthor,"<br/></h3><br/>Version ",version,"<br/>Printed: ","%C",dayofcalendar(),"<br/>&nbsp;</br>&nbsp;</br>#:  __________</div>");
        fprintln(inh,"<div class=\"preface\"><h1>Front Matter</h1><OL type=\"",ltypes[0],"\">");
        foreach (s in fm[nn]) {
            fp = fopen(bdir+s[fmname]+outext,"r");
            if (isint(fp)) oxrunerror("output file "+bdir+s[fmname]+outext+" failed to open");
            if (nn==GLOSS) fprintln(inh,"<div class=\"break\"> </div>");
            fprintln(inh,"<h3><LI>",s[fmtitle],"</LI></h3><div ",nn!=GLOSS ? "id=\"split\">" : ">");
            inbody = FALSE;
            while(fscan(fp,"%z",&line)>FEND) {
                if (!inbody)
                    inbody = strfind(line,"<body>")>-1;
                else {
                    if (strfind(line,"</body>")>-1)
                        inbody=FALSE;
                    else fprintln(inh,line);
                    }
                }
            fprintln(inh,"</div>");
            if (nn==TOC) fprintln(inh,"<div class=\"break\"> </div>");
            fclose(fp);
            }
        fprintln(inh,"</OL></div>");
        //fprintln(inh,"<OL type=\"I\"");
        made = TRUE;
        }
    else {
        decl h = fopen(bdir+output+outext,"w");
        if (isint(h)) oxrunerror("output file "+bdir+output+outext+" failed to open");
        printheader(h,booktitle);
        fprintln(h,"<div style=\"width:900px\"><h1>",booktitle,"<br/>&nbsp;<br/>&nbsp;<br/>",bookauthor,"</h1></div>");
        fprintln(h,mreplace(footer,{{"%prev%",""},{"%next%","001"}}));
        fclose(h);
        }
    }
exercises::exercises(sect) {
    section(0);
    notempty = FALSE;
    parent = sect;
    sect.myexer = this;
    level = 3;
    title = "Exercises for <em>"+parent.title+"</em>";
    pref = "ex";
    source = pref+sprint("%03u",parent.index);
    output = source;
    exdoc = fopen(sdir+source+inext,"w");
    if (isint(exdoc)) oxrunerror("output file "+sdir+source+inext+" failed to open");
    fprintln(exdoc,"<OL class=\"exer\">");
    }
exercises::accum(line) {    fprintln(exdoc,line);    }
exercises::append(ord,fn) {
    this.ord = ord+1;
    entry(fn);
    contents |= this;
    }
exercises::make(inh) {
    if (isfile(exdoc)) {
        fprintln(exdoc,"</OL>");
        fclose(exdoc);
        exdoc = 0;
        }
    section::make(inh);
    }
section::parse(line) {
    decl eb,ch;
    sscan(line,"%z",&ch);
    eb = strfind(ch,rbr);
    title = ch[:eb-1];
    output = pref+sprint("%03u",index);
    if (eb<sizeof(ch)-2) {
        ch = ch[eb+1:];
        if (ch[0:0]==lp) {
            eb = strfind(ch,rp);
            source = ch[1:eb-1];
            }
        }
    }
section::entry(f) {
    fprintln(f,"<LI><a href=\"",output,outext,"\" target=\"contentx\">",title,"</a></LI>");
    }
section::glossentry(line) {
    if (isfile(fm[GLOSS][fptr])) {
        //print("found a term: ");
        decl sb, se, ib, ie, tb,db,de,ipl;
        sb = strifind(line[0],dfcontl)+sizeof(dfcontl);
        se = strifindr(line[0],dfcontr)-1;
        db = strifind(line[0],dfbeg);
            ib = strifind(line[0][db:],"title=\"")+7;
            ie = strifind(line[0][db+ib:],"\"");
            tb = strifind(line[0][db+ib+ie:],">")+1;
            ipl = db+ib+ie+tb;
            de = ipl+strifind(line[0][ipl:],dfend)-1;
        fprint(fm[GLOSS][fptr],"<LI><a href=\"",output,outext,"#D",ndefn,"\" target=\"contentx\">");
        fprint(fm[GLOSS][fptr],line[0][ipl:de],"</a>");
        fprintln(fm[GLOSS][fptr],"<DD>",line[0][max(db+ib,0):max(0,db+ib,db+ib+ie-1)],"&emsp; &emsp;<em>See:",replace(title,"<br/>",":","i"),"</em></DD></LI>");
        //  println("** ",line[0]);
        line[0] = line[0][:ipl-2]+" id=\"D"+sprint(ndefn)+"\""+line[0][ipl-1:];
        // println(line[0],"**");
        ++ndefn;
    }
    }
exercises::entry(f) {
    fprintln(f,"<DT><a href=\"",output,outext,"\" target=\"contentx\">",title,"</a></DT>");
    }
section::section(index) {
    this.index = index;
    pref = "s";
    ndefn = uplev = myexer = child = level =source = anch = 0;
    title = output = "";
    notempty = TRUE;
    }
section::make(inh) {
    decl h,ftype,ftemp;
    ftype = 0;  //initialize to avoid error until first figure is found
    if (isfile(inh)) {
         h = inh;
/*         if (ord==1) fprintln(h,"<OL  type=\"",ltypes[level],"\" class=\"toc",level,"\" >");
         else for(decl i=0;i<uplev;++i) lend(h);
         fprintln(h,"<h",level,"><a name=\"",output,"\"><LI>",title,"</LI></a></h",level,">");*/
         fprint(h,"<OL  type=\"",ltypes[level],"\" class=\"toc",level,"\" >");
         fprintln(h,"<h",level,"><a name=\"",output,"\"><LI value=",ord,">",title,"</LI></a></h",level,"></OL>");

         }
    else {
        h = fopen(bdir+output+outext,"w");
        if (isint(h)) oxrunerror("output file "+bdir+output+outext+" failed to open");
        printheader(h,title);
        fprintln(h,"\n<OL  type=\"",ltypes[level],"\" \">",
                   "<h",level,"><a name=\"",output,"\"><LI value=",ord,">",title,"</a></LI></h",sprint(level),"></OL>");
        }
    if (isstring(source)) {
        decl ss = fopen(sdir+source+inext,"r"),line,curtit = "", nsc,eof;
        if (isfile(ss)) {
            while(( (nsc=fscan(ss,"%z",&line))>FEND)) {
                if (nsc==0) { fprintln(h,""); continue;}  //zero character line read in
                if (line==exstart) {
                    //print("E");
                    if (isclass(exsec)) {
                        fprintln(h,"<details><summary>Exercises</summary><UL class=\"steps\">");
                        exsec.notempty = TRUE;
                        }
                    do {
                        eof = fscan(ss,"%z",&line)==FEND;
                        if (line!=exend) {
                            if (isclass(exsec) ){
                                fprintln(h,line);
                                exsec->accum(line);
                                }
                            }
                        } while(line!=exend && !eof);
                    //println("X");
                    if (isclass(exsec) ) fprintln(h,"</UL></details>");
                    }
                else {
                    if ((sizeof(line)>fmlast && (ftemp=find(figmarks,line[:fmlast]))>-1)) {
                         ftype = ftemp;  // This sets ftype until a new figmark shows up
                         ++fign[ftype];
                         fprintln(h,"<a name=\"",figprefix[ftype],fign[ftype],"\"></a>");
                         curtit = line[fmlast+1:strfind(line,exend)-1];
                         if (isfile(fm[1+ftype][fptr]))
                            fprintln(fm[1+ftype][fptr],"<li><a href=\"#",figprefix[ftype],fign[ftype],"\">",curtit,"</a></li>");
                         }
                    else {
                       if (strfind(line,dfbeg)>-1) glossentry(&line);
                        //next line uses current ftype, so figtag replace with the last one encountered
                       fprintln(h,replace(line,figtag,"<h4>"+figtypes[ftype]+sprint(fign[ftype])+". "+curtit+"</h4>"));
                       }
                    }
                }
            fclose(ss);
            }
        else {
            oxwarning("Source file not found: "+source);
            fprintln(h,"<div class=\"break\"></div><blockquote class=\"upshot\"><h5>",title,"</h5> is not ready. This page is left blank to provide some room for taking notes.</blockquote><div class=\"break\"></div>");
            //notempty = FALSE;
            }
        }
    else if (level<2 && child>0) {
        fprintln(h,"<blockquote class=\"toc\"><h4>Contents</h4>");
        lbeg(h,level+1);
        decl c=index+1;
        do {
            if (contents[c].level==level+1 && contents[c].notempty) contents[c]->entry(h);
            } while (++c<sizeof(contents)&&contents[c].level>level);
        lend(h);
        fprintln(h,"</blockquote>");
        }
    if (!isfile(inh)) {
        fprintln(h,mreplace(footer,{{"%prev%",sprint("%03u",index-1)},
                                    {"%next%",sprint("%03u",index+1)}}));
        fclose(h);
        }
    }

section::slides() {
    decl h,ftype,ftemp;
    if (isstring(source)) {
        h = fopen(bdir+spref+output+outext,"w");
        if (isint(h)) oxrunerror("output file "+bdir+spref+output+outext+" failed to open");
        printheader(h,title);
        fprintln(h,"<OL  type=\"",ltypes[level],"\" \"><h",level,"><a name=\"",output,"\"><LI value=",ord,">",title,"</a></LI></h",sprint(level),"></OL>");
        decl ss = fopen(sdir+source+inext,"r"),line,curtit = "", nsc,eof;
        if (isfile(ss)) {
            while(( (nsc=fscan(ss,"%z",&line))>FEND)) {
                if (nsc==0) { fprintln(h,""); continue;}  //zero character line read in
                if (line==exstart) {
                    if (isclass(exsec)) fprintln(h,"<details><summary>Exercises</summary><UL class=\"steps\">");
                    do {
                        eof = fscan(ss,"%z",&line)==FEND;
                        if (line!=exend) {
                            if (isclass(exsec) ){
                                fprintln(h,line);
                                exsec->accum(line);
                                }
                            }
                        } while(line!=exend && !eof);
                    if (isclass(exsec) ) fprintln(h,"</UL></details>");
                    }
                else {
                    if ((sizeof(line)>fmlast && (ftype=find(figmarks,line[:fmlast]))>-1)) {
                         ++fign[ftype];
                         fprintln(h,"<a name=\"",figprefix[ftype],fign[ftype],"\"></a>");
                         curtit = line[sizeof(figmarks[ftype]):strfind(line,exend)-1];
                         }
//                    else{
//                       fprintln(h,replace(line,figtag,"Exhibit "+sprint(fign[ftype])+". "+curtit));
//                       }
                    }
                }
            fclose(ss);
            }
        fprintln(h,mreplace(footer,{ {"s%prev%",spref+sprint("%03u",index-1)},
                                     {"s%next%",spref+sprint("%03u",index+1)}}));
        fclose(h);
        }
    }


document::build(sdir,bdir,tocfile) {
    decl done, htoc, toc, ind, book,  ch,line,n,iprev,sect,curp, curx,nlev;
    fm =        {{"toc","Table of Contents",0},
                {"figlist","List of Figures",0},
                {"deflist","List of Definitions",0},
                {"alglist","List of Algorithms",0},
                {"tablist","List of Tables",0},
                {"glossary","Glossary of Defined Terms &amp; Special Symbols",0}};
    lev = 0;
    if (sdir!="") this.sdir = sdir;
    if (bdir!="") this.bdir = bdir;
    if (tocfile!="") this.TOCFILE = tocfile+tocext;
    fign = zeros(sizerc(figmarks),1);
    fignicks = new array[sizerc(figmarks)];
    toc = fopen(sdir+TOCFILE);
    if (isint(toc)) oxrunerror("input file "+sdir+TOCFILE+" failed to open");
    sect = new titlepage(toc);
    decl s;
    for(s =0; s<sizeof(fm); ++s) {
        fm[s][fptr] = fopen(bdir+fm[s][fmname]+outext,"w");
//        println("#### ",s," ",bdir+fm[s][fmname]+outext);
        if (isint(fm[s][fptr])) oxrunerror("output file "+bdir+fm[s][fmname]+outext+" failed to open");
        printheader(fm[s][fptr],booktitle);
        fprintln(fm[s][fptr],"<span style=\"font-size:small;\">\n<OL>"); //<h3>",fm[s][fmtitle],"</h3>
        }
    curx = curp = matrix(0);
    sect.title = booktitle;
    contents = {sect};
    exsec = 0;
    do {
       fscan(toc,"%z",&line);
       sscan(line,"%c",&ch);
       println(ch," ",line);
       done = ch=='#';
       if (!done) {
            sect = new section(sizeof(contents));
            iprev = sect.index-1;
            nlev = 0;
            do {
                sscan(&line,"%c",&ch);
                if (ch=='*') ++nlev;
                } while(ch=='*');
            sect.level=nlev;
            if (nlev>contents[iprev].level) {
                sect.ord = 1;
                contents[iprev].child = sect.index;
                curp |= sect.parent = iprev;
                curx |= 0;
                lbeg(fm[TOC][fptr],nlev);
                if (nlev==3) fprintln(fm[TOC][fptr],"<details class=\"toc\" open><summary>sections</summary>");
                ++lev;
                }
            else {
                sect.ord = contents[curx[nlev-1]].ord+1;
                curx[nlev-1] = sect.index;
                }
            }
        if (done) nlev = 1;
        while(nlev<lev) {
            if (lev==3) fprintln(fm[TOC][fptr],"</details>");
            lend(fm[TOC][fptr]);
            ++sect.uplev;
            --lev;
            curp = curp[:max(0,rows(curp)-2)];
            curx = curx[:max(0,rows(curp)-2)];
            }
        if (nlev==1) {
            if (isclass(exsec)) {
                exsec->append(sect.ord+1,fm[TOC][fptr]);
//                lend(fm[0][fptr]);
                }
            }
        if (!done) {
            sect->parse(line);
            sect->entry(fm[TOC][fptr]);
            if (nlev==1) exsec = new exercises(sect);
            contents |= sect;
            }
        } while(!done);
//  lend(fm[TOC][fptr]);
  decl f;
  for (f=1;f<sizeof(fm);++f) {
    fprintln(fm[TOC][fptr],"<a href=\"",fm[f][fmname],outext,"\" target=\"contentx\">",fm[f][fmtitle],"</a>");
    }
  fprintln(fm[TOC][fptr],"</span>");
  fclose(fm[TOC][fptr]); fm[TOC][fptr] = 0;
  foreach(s in contents) {
    if (isclass(s.myexer)) exsec=s.myexer;
    s->make();
    }
  exsec = 0;  //exercises already made.
  fign[] = 0;   // reset figure numbers
  htoc = fopen(bdir+"book"+outext,"w");
  for (f=TOC+1;f<sizeof(fm);++f) {
//    println("$$$ ",f," ",fm[f][fmname]+outext);
    lend(fm[f][fptr]);
    fprintln(fm[f][fptr],"</span>");
    fclose(fm[f][fptr]);
    fm[f][fptr] = 0;
//    println(fm[f][fmtitle]," closed");
    }
  printheader(htoc,booktitle);
  //fprintln(htoc,replace(head,ttag,booktitle));
  foreach(s in contents)    if (s.notempty) s->make(htoc);
  lend(htoc);
  fprintln(htoc,mreplace(footer,{ {"%prev%",""},{"%next%",""}}));
  fclose(htoc);
  htoc = 0;
  exsec = 0;  //exercises already made.
  fign[] = 0;   // reset figure numbers
  foreach(s in contents) if (s.notempty) s->slides();
  }
