#include "doc-build.oxh"

document::findmark(line) {
	return strfind(figmarks,line[:min(fmlast,sizeof(line)-1)]);
	}

mreplace(tmplt,list) {
    decl txt = tmplt, r;
    foreach(r in list) txt = replace(txt,r[0],r[1]);
    return txt;
    }

/**Begin a list of sub-sections at level nlev.**/
document::lbeg(f,nlev,tclass) {
    fprintln(f,"<OL type=\"",ltypes[nlev],"\" class=\"toc",sprint(nlev),"\">");
    }
/**End a list of sub-sections.**/
document::lend(f,nlev) { fprintln(f,"</OL>"); }

/**Print the HTML header for a file, inserting book-specific tags.**/
document::printheader(h,title,next) {
        fprintln(h,mreplace(head0,{{atag,bkvals[BOOKAUTHOR]},{"<br/>",": "}}));
		fprintln(h,mreplace(csstemp,{{csstag,csstypes[buildtype]}}));
        fprintln(h,mreplace(mathjax,{{"%scale%",scales[buildtype]}}));
        fprintln(h,mreplace(headtitle,{{ttag,bkvals[BOOKTITLE]},{"<br/>",": "}}));
        }
/**Print the HTML header for an individual slide, inserting book-specific tags.**/
section::printslideheader(h) {
        fprintln(h,mreplace(head0,{{atag,bkvals[BOOKAUTHOR]},{"<br/>",": "}}));
		fprintln(h,mreplace(csstemp, {{csstag,csstypes[buildtype]}}));
		fprintln(h,mreplace(mathjax,{{"%scale%",scales[buildtype]}}));
        fprintln(h,mreplace(slidetitle,{{ttag,bkvals[BOOKTITLE]},{"<br/>",": "}}));
        }
		
section::printfooter(h,title,prev,next) {
    fprintln(h,"</div>",mreplace(footer,{{"%prev%",prefs[buildtype]+prev},
                                {"%next%",prefs[buildtype]+next},
                                {"%tttag%",bkvals[BOOKTAG]+" "+title},
                                {atag,bkvals[BOOKAUTHOR]},
                                {"%year%",timestr(today())[:3]},
                                {"%affiliation%",bkvals[AFFILIATION]},
								{"%license%",license}
                                }));
    }

section::printslidefooter(h) {
    fprintln(h,"</div>",mreplace(footer,{{"%prev%",prefs[buildtype]+sprint("%03u",index-1)},
                                {"%next%",prefs[buildtype]+sprint("%03u",index+1)},
                                {"%tttag%",bkvals[BOOKTAG]+" "+title+" "+sprint(source)},
                                {atag,bkvals[BOOKAUTHOR]},
                                {"%year%",timestr(today())[:3]},
                                {"%affiliation%",bkvals[AFFILIATION]},
								{"%license%",license},
								{"%page%",sprint(index)}
                                }));
    }

	
/**Create the cover page of the book, reading info from the TOC file.**/
titlepage::titlepage() {
    section(0);
    decl line, ch, pind,done;
    do {
       fscan(tocf,OxScan,&line);
       sscan(line,"%c",&ch);
       done = ch=='#';
       if (!done) {
            sscan(&line,"%T",&ch);
            pind=strfind(partags,ch[0]);
            if (pind!=FEND)
                {
            	sscan(&line,"%T",&ch);
				sscan(line,OxScan,&ch);
				bkvals[pind] = ch;
				println(pind," ",bkvals[pind]);
				}
            else println("parameter ",ch[0]," not found.");
            }
    } while (!done);
    title = bkvals[BOOKTITLE];
    pref = "";
    source = "title";
    output = source;
    ord = 1;
    parent=-1;
    }

titlepage::make(inh) {
    if (isfile(inh)) {
        decl s,sfname,inlines,begbody,endbody,nn;
        fprintln(inh,"<div class=\"tp\"><h1>",bkvals[BOOKTITLE],"</h1><h2>",bkvals[BOOKSUB],"</h2><br/>&nbsp;<br/><h3>",bkvals[BOOKAUTHOR],"<br/></h3><br/>Version ",bkvals[VERSION],"<br/>Printed: ","%C",dayofcalendar(),"<br/>&nbsp;</br>&nbsp;</br>#:  __________<br/>License:",biglicense,"</div>");
        fprintln(inh,"<div class=\"preface\"><h1>Front Matter</h1><OL type=\"",ltypes[0],"\">");
        foreach (s in fm[nn])
           if ( puboption>=s[MinLev] && s[fnotempty]){
            	if ((fread(sfname= bdir+s[fmname]+outext,&inlines,'s')<=0))
					oxrunerror("output file "+sfname+" failed to open");
				if (( (begbody = strfind(inlines,"<body>"))!=FEND)) {
					endbody = strfind(inlines,"</body");
					fprintln(inh,nl,inlines[begbody+6:endbody-1]);
            		if (nn==TOC) fprintln(inh,"<div class=\"break\"> </div>");
					}
            }
        fprintln(inh,"</OL><h1>",bkvals[BOOKTITLE],"</h1></div><div class=\"break\"> </div>");
        }
    else {
        decl h = fopen(bdir+prefs[buildtype]+output+outext,"w");
        if (isint(h)) oxrunerror("output file "+bdir+prefs[buildtype]+output+outext+" failed to open");
        printheader(h,bkvals[BOOKTITLE]);
        fprintln(h,"<div class=\"tp\"><h1>",bkvals[BOOKTITLE],"</h1><br/><h2>",bkvals[BOOKSUB],"</h2><h3>&nbsp;<br/>",bkvals[BOOKAUTHOR],"</h3></div>");
        printfooter(h,"","","001");
        //        fprintln(h,mreplace(footer,{{"%prev%",""},{"%next%","001"},}));
		fprintln(h,endhtml);
        fclose(h);
        }
    }

/**Exercises associated with a section.**/
exercises::exercises(sect) {
    section(sect.index);
	myclass="text";
    notempty = FALSE;
    parent = sect;
    sect.myexer = this;
    level = 3;
    title = "Exercises for <em>"+parent.title+"</em>";
    pref = "ex";
    source = pref+sprint("%03u",parent.index);
    output = source;
    exdoc = fopen(sect.mysdir+source+inext,"w");
    if (isint(exdoc)) oxrunerror("output file "+sect.mysdir+source+inext+" failed to open");
	//printslideheader(exdoc);
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
/** Parse a line fro the **/
section::parse(line) {
    decl eb,ch;
    sscan(line,OxScan,&ch);
    eb = strfind(ch,rbr);
	if (eb==FEND) println("Error in TOC :",line);
    title = ch[:eb-1];
    output = sprint("%03u",index);
    if (eb<sizeof(ch)-2) {
        ch = ch[eb+1:];
        if (ch[0:0]==lp) {
            eb = strfind(ch,rp);
            source = ch[1:eb-1];
            }
        }
    }
section::entry(f) {
    decl loc = buildtype==BOOK ? "#"+prefs[SECTION]+output : prefs[SECTION]+output+outext;
    fprintln(f,"<LI><a href=\"",loc,"\" target=\"content\">",title,"</a></LI>");
    }

section::codesegment(line) {
	decl fname,lno,cf,cline,templ, oline, inlines;
	fname = line[fmlast+2:strfindr(line,codeend)-2];
	templ = 		
	"<DD id=\"%FFF%\"><pre><span class=\"fname\"><em><a href=\"./code/%FFF%\">%FFF%</a></em></span>\n";
	oline = replace(templ,"%FFF%",fname);
	cf = fread(bdir+"code\\"+fname,&inlines,'s');
	lno = 0;
	if (cf>0) {
		do {
			if (sscan(&inlines,OxScan,&cline)==FEND) break;
			++lno;
			oline |= sprint("%2.0f",lno,":    ",cline,nl);
			} while (TRUE);
		}
	else
		oxwarning("Code file "+fname+" not found");
	oline |= "</pre></dd>";
	//fprintln(h,oline);
	if (isfile(fm[CODE+1][fptr])) {
        decl loc = buildtype==BOOK ? "" : sprint(prefs[SECTION],output,outext);
		fprintln(fm[CODE+1][fptr],"<li><a href=\"",loc,"#",fname,"\">",fname,"</a></li>");
//		if (!fm[CODE+1][fnotempty]) println(fm[CODE+1][fmname]);
		fm[CODE+1][fnotempty]=TRUE;		
		}
	return oline;
	}

section::glossentry(line) {
    if (isfile(fm[GLOSS+1][fptr])) {
        decl sb, se, ib, ie, tb,db,de,ipl;
        sb = strifind(line[0],dfcontl)+sizeof(dfcontl);
        se = strifindr(line[0],dfcontr)-1;
        db = strifind(line[0],dfbeg);
            ib = strifind(line[0][db:],"title=\"")+7;
            ie = strifind(line[0][db+ib:],"\"");
            tb = strifind(line[0][db+ib+ie:],">")+1;
            ipl = db+ib+ie+tb;
            de = ipl+strifind(line[0][ipl:],dfend)-1;
        decl loc = buildtype==BOOK ? "" : sprint(prefs[SECTION],output,outext);
        fprint(fm[GLOSS+1][fptr],"<LI><a id=\"",line[0][ipl:de],"\" href=\"",loc,"#D",ndefn,"\" target=\"content\">");
        fprint(fm[GLOSS+1][fptr],line[0][ipl:de],"</a>");
        fprintln(fm[GLOSS+1][fptr],"<DD>",line[0][max(db+ib,0):max(0,db+ib,db+ib+ie-1)],"&emsp; &emsp;<em>See:",replace(title,"<br/>",":","i"),"</em></DD></LI>");
        line[0] = line[0][:ipl-2]+" id=\"D"+sprint(ndefn)+"\""+line[0][ipl-1:];
        ++ndefn;
//		if (!fm[GLOSS+1][fnotempty]) println(fm[GLOSS+1][fmname]);
		fm[GLOSS+1][fnotempty]=TRUE;
    }
    }
exercises::entry(f) {
    decl loc = buildtype==BOOK ? "#"+prefs[SECTION]+output : prefs[SECTION]+output+outext;
    fprintln(f,"<DT><a href=\"",loc,"\" target=\"content\">",title,"</a></DT>");
    }
exercises::eblock(href) {
    fprintln(exdoc,"<DD class=\"noprint\"><a href=\"",href,"\" target=\"content\">&larr;</a></DD>");
	}
section::section(index) {
    this.index = index;
    pref = "s";
    ndefn = uplev = myexer = child = level =source = anch = 0;
    title = output = "";
    notempty = TRUE;
	minprintlev = OUTLINE;
	myclass=slideclass;
	mysdir = sdir;  //copies current source from toc if changed.
    }
countkbs(ss){
	decl kbvals = "1 2 3 4 5 6 7 8 9 0 A B C D",smxi=sizeof(ss),dds="$$",
		nxti, nxtf, tstart,tend, tmp, outs="", mxfrag=0,etarg,
		 alld,lsti,ndsp,dstart,dend,targ = "\"kb\"",vtarg=" value=\"", eqt;

	/* find all display math */
	alld = <>; dend = 0;
	while (( (dend<smxi) && (dstart=strifind(ss[dend:],dds))!=FEND )) {
		 tmp = dend+dstart+2+strfind(ss[dend+dstart+2:],dds)+1;
		 alld |= (dend+dstart)~tmp;
		 dend=tmp+1;
		 }
	/* find and process all kb tags */
	lsti=0;
	while(( (lsti<smxi) && (nxti=strifind(ss[lsti:],targ))!=FEND)) {
		tstart = strfindr(ss[lsti:lsti+nxti],"<");
		// find if tag is inside display math
		ndsp=0;
		while( ndsp!=FEND && ndsp<rows(alld) && ((alld[ndsp][0]>=lsti+tstart)||(lsti+tstart>=alld[ndsp][1])) )
			{
			++ndsp;
			}
		if (ndsp>=rows(alld)) ndsp=FEND;

		//find value of kb and end of tag
		tend = strfind(ss[lsti+tstart:lsti+nxti]," ");
		etarg = "</"+ss[lsti+tstart+1:lsti+tstart+tend-1]+">";
		nxti+=sizeof(targ)+sizeof(vtarg)-1;
		++nxti;
		eqt = strfind(ss[lsti+nxti:],"\"");
		sscan(ss[lsti+nxti:lsti+nxti+eqt-1],"%u",&nxtf);
		nxtf = min(nxtf,kblim);
//		if (2*(nxtf-1)>=sizeof(kbvals)) println(ss[lsti+tstart:]);
		mxfrag=max(nxtf,mxfrag);

		//replace input tag without output, depending on if display math or not
		if (ndsp==FEND) {
			outs|=ss[lsti:lsti+nxti-1];
			outs|=kbvals[2*(nxtf-1):];
			nxti +=eqt; //point to close-quote
			tmp = lsti+nxti;
			lsti = tmp+strifind(ss[tmp:],etarg)+sizeof(etarg);
			outs |= ss[tmp:lsti];
			++lsti;  //get past </span>
			}
		else {
			println("Embedded ");
			outs|=ss[lsti:lsti+tstart-1]
			      + "\\class{kb}{\\style{value:\""
				  +	kbvals[2*(nxtf-1):]
			      + "\"}{";
			tmp  = lsti+tstart+strifind(ss[lsti+tstart:],">")+1;
			lsti = tmp+strifind(ss[tmp:],etarg);
			outs|=ss[tmp:lsti-1]+"}}";
			lsti += sizeof(etarg);
			}
	 	}
	if (lsti<smxi) outs |= ss[lsti:];
	return {outs,mxfrag};
	}
section::make(inh) {
    decl h,ftype,ftemp,notdone,curxname,outlines;
    ftype = 0;  //initialize to avoid error until first figure is found
	curxname = 0;
    if (isfile(inh))
         h = inh;
    else {
        h = fopen(bdir+prefs[buildtype]+output+outext,"w");
        if (isint(h)) oxrunerror("output file "+bdir+prefs[buildtype]+output+outext+" failed to open");
        }
    outlines=sprint(nl,"<OL  type=\"",ltypes[level],"\" \">",
                   "<h",level,"><a id=\"",prefs[SECTION]+output,"\"><LI value=",ord,">",title,"</a></LI></h",sprint(level),"></OL>",nl);
	if (isstring(source)&&source!=UD) {
        decl ss,inlines,line,curtit = "", nsc,eof,slideno;
		ss=fread(mysdir+source+inext,&inlines,'s');
        if (ss>0) {
			[inlines,mxkb]=countkbs(inlines);
        	if (!isfile(inh)) printslideheader(h);
            while(( (nsc=sscan(&inlines,OxScan,&line))>FEND)) {
                if (nsc==0) { if (puboption>=PUBLISH) outlines|=nl; continue;}  //zero character line read in
                if (line==exstart) {   //Exercises beginning
                    if (isclass(exsec)) {
                        if (puboption>=PUBLISH) {
							outlines|=sprint("<span id=\"EB",++curxname,"\">",exopen,"</span>",nl);
                            decl loc = buildtype==BOOK ? "" : sprint(prefs[SECTION],output,outext);
							exsec->eblock(loc+"#EB"+sprint(curxname));
							}
                        exsec.notempty = TRUE;
                        }
                    do {
                        nsc = sscan(&inlines,OxScan,&line);
                		if (nsc==0) { if (puboption>=PUBLISH) outlines|=nl; continue;}  //zero character line read in
						eof = nsc==FEND;
						notdone = strfind(line,exend)==FEND;
						if (notdone && !eof) {
							ftemp=findmark(line);
                            if (isclass(exsec) ){
								if (ftemp!=FEND) {
                                    ++fign[ftemp];
							        if (1+ftemp==CODE && (puboption>=PUBLISH)) {
                                        line=codesegment(line);
                                        }
									}
                                if (puboption>=PUBLISH) outlines|=line+nl;
                                exsec->accum(line);
                                }
                            }
                        } while(notdone && !eof);
                    if (isclass(exsec) && puboption>=PUBLISH) outlines|=exclose;
                    }
                else {
                    if (line==keystart) {	//Key or Instructor note beginning
						if (puboption>=KEY) outlines|=keyopen;
						do {
                            eof = sscan(&inlines,OxScan,&line)==FEND;
							notdone = strfind(line,keytag+comend)==FEND;
                            if (puboption>=KEY&&notdone) outlines|=line;
                            } while (notdone && !eof);
                        if (puboption>=KEY) outlines|=keyclose;
                        }
                    else {	//Ordinary text
                        if (( (ftemp=findmark(line))!=FEND )) {
                            ftype = ftemp;  // This sets ftype until a new figmark shows up
                            ++fign[ftype];
							if (1+ftype==CODE && (puboption>=PUBLISH)){
									line = codesegment(line);
									outlines |= line;
									continue;
									}
							else {
                            	if (puboption>=PUBLISH) outlines|=sprint("<a id=\"",figprefix[ftype],fign[ftype],"\"></a>",nl);
								if (strfind(line,figtags[ftype]+comend)==FEND) println("Error in ",title,nl,"   ",figtags[ftype]+comend,nl,line);
                            	curtit = line[fmlast+2:strfindr(line,figtags[ftype]+comend)-1];
                            	if (isfile(fm[1+ftype][fptr]))
                                	if (puboption>=PUBLISH) {
                                        decl loc = buildtype==BOOK ? "" : sprint(prefs[SECTION],output,outext);
										fprintln(fm[1+ftype][fptr],"<li><a href=\"",loc,"#",figprefix[ftype],fign[ftype],"\">",curtit,"</a></li>");
//										if (!fm[ftype+1][fnotempty]) println(fm[ftype+1][fmname]);										
										fm[1+ftype][fnotempty]=TRUE;
										}										
								}									
                            }
                        else {
                            if (strfind(line,dfbeg)>-1) glossentry(&line);
                            //next line uses current ftype, so figtag replace with the last one encountered
                            if (puboption>=PUBLISH )
                                outlines|=replace(line,figtag,"<h3 class=\"fig\">"+figtypes[ftype]+sprint(fign[ftype])+". "+curtit+"</h3>"+nl)+nl;
                            }
                        }
                    }
                }
			if (buildtype==SLIDE) {
				for (slideno=0;slideno<=mxkb;++slideno)
					fprintln(h,"<div class=\"slide\" id=\"",sclass[slideno:slideno],"\" onclick=\"window.location.href='",slideno==mxkb ? prefs[buildtype]+sprint("%03u",index+1)+outext : "#"+sclass[slideno+1:slideno+1],"'\" >"+nl,
								outlines,nl,"</div>");
				}
			else
				fprintln(h,"<div class=\"",myclass,"\" id=\"",sclass[0:0],"\">",nl,outlines);
            }
        else {
            oxwarning("Source file not found: "+source);
            if (puboption>=PUBLISH)
				fprintln(h,"<div class=\"break\"></div><blockquote class=\"upshot\"><h5>",title,"</h5> is not ready. This page is left blank to provide some room for taking notes.</blockquote><div class=\"break\"></div>");
            //notempty = FALSE;
            }
        }
	else if (isstring(source) && puboption>=PUBLISH) {  //MUST BE UDRAW.
		if (!isfile(inh)) printslideheader(h);
		fprintln(h,"<div class=\"slide\" id=\"a\" onclick=\"window.location.href='",prefs[buildtype]+sprint("%03u",index+1)+outext,"'\" >",nl,
		"<h",level,">",title,"<br/>Space to draw the illustration</h",level,">");
		}
    else if (level<3 && child>0 && puboption>=PUBLISH ) {
		if (!isfile(inh)) printslideheader(h);
		fprintln(h,"<div class=\"slide\" id=\"a\" onclick=\"window.location.href='",
					prefs[buildtype]+sprint("%03u",index+1)+outext,"'\" >\n",outlines,"\n<blockquote class=\"toc\"><h4>Contents</h4>");
        lbeg(h,level+1);
        decl c=index+1;
        do {
            if (contents[c].level==level+1 && contents[c].notempty) contents[c]->entry(h);
            } while (++c<sizeof(contents)&&contents[c].level>level);
        lend(h,level+1);
        fprintln(h,"</blockquote>");
        }
    if (!isfile(inh)) {
        if (puboption>=PUBLISH) {
			printslidefooter(h);
			fprintln(h,endhtml);
			}
        fclose(h);
        }
	else fprintln(inh,"</div>"); // printslidefooter(inh);
    }


document::readtoc() {
	decl ch,done,line, iprev,nlev;
    do {
       fscan(tocf,OxScan,&line);
       sscan(line,"%c",&ch); 		//println(ch," ",line);
       done = ch==tocendtag;		// rest of toc file ignored
	   if (ch==skiptag)	continue;   // comment line in toc
	   if (ch==tocsectag) {
	   		slideclass=line[1:];
			continue;
	   		}
	   if (ch==srctag) {
	   		sdir = line[1:];
			continue;
	   		}
       if (!done) {
            sect = new section(sizeof(contents));
            iprev = sect.index-1;
            nlev = 0;
			println(line);
            do {
                sscan(&line,"%c",&ch);
                if (ch==lvtag) ++nlev;
                } while(ch==lvtag);
            sscan(&line,"%1u",&ch);   //minimum print level for this section.
			sect.minprintlev = ch;
			sscan(&line,"%c",&ch,"%c",&ch);  //skip closing and opening bracket
            sect.level=nlev;
            if (nlev>contents[iprev].level) {  // going down a level
                sect.ord = 1;
                contents[iprev].child = sect.index;
                curp |= sect.parent = iprev;
                curx |= 0;
				begun[nlev] = FALSE;
 				if (puboption>=sect.minprintlev) {
                	if (nlev>=2) fprintln(fm[TOC][fptr],tocopen);
                	lbeg(fm[TOC][fptr],nlev);
					begun[nlev]=TRUE;
					}
                ++lev;
                }
            else
/*            if (nlev<contents[iprev].level) {  //going up levels
                    println("*** ",isclass(contents[curx[nlev]-1],"exercise")," ",nlev," ",curx');
                    sect.ord = (isclass(contents[curx[nlev]-1],"exercise"))
                                 ? contents[curx[nlev-1]].parent.ord+1
                                 : contents[curx[nlev-1]].ord+1;
                    curx[nlev-1] = sect.index;
                }
            else */
            {      //same level
//                if (nlev<contents[iprev].level) println("--- ",nlev," ",curx');
                if (nlev==EXERLEV && isclass(contents[curx[nlev-1]],"exercises"))
                    {println(curx[nlev-1]," ",classname(contents[curx[nlev-1]])," ",contents[curx[nlev-1]].title);
                        sect.ord = contents[curx[nlev-1]].parent.ord+1;
                        }
                else
                    sect.ord = contents[curx[nlev-1]].ord+1;
                curx[nlev-1] = sect.index;
                }
            }
        if (done) nlev = 1;
        while(nlev<lev) {
            if (puboption>=sect.minprintlev) {
				if (begun[nlev]) lend(fm[TOC][fptr],nlev);
        if (nlev==EXERLEV) {
            if (isclass(exsec)&&puboption>=sect.minprintlev) {
                exsec->append(sect.ord+1,fm[TOC][fptr]);
                }
            }
	            if (lev>EXERLEV) fprintln(fm[TOC][fptr],tocclose);
				}
            ++sect.uplev;
            --lev;
            curp = curp[:max(0,rows(curp)-2)];
            curx = curx[:max(0,rows(curp)-2)];
            }
        if (!done) {
            sect->parse(line);
            sect->entry(fm[TOC][fptr]);
            if (nlev==EXERLEV) exsec = new exercises(sect);
            contents |= sect;
            }
        } while(!done);
  fprintln(fm[TOC][fptr],"</details><LI><h3>Lists of Items</h3></LI><details open>");
	}

document::build(sdir,bdir,tocfile,puboption) {
    decl  htoc,  ind, book, n;
    bkvals = new array[NBOOKPARAMS];
	begun = zeros(8,1); //up to 8 subsections	
	document::puboption = puboption;
	figmarks = {};
	foreach (n in figtags) figmarks |= {comstart+n};
	buildtype = SECTION;

    figtag = comstart+TitleHolder+"-->";
    exstart = comstart+extag;
    keystart = comstart+keytag;
    lev = 0;
    if (sdir!="") this.sdir = sdir;
    if (bdir!="") this.bdir = bdir;
    if (tocfile!="") this.TOCFILE = tocfile+tocext;
    fign = zeros(sizerc(figmarks),1);
    fignicks = new array[sizerc(figmarks)];
    tocf = fopen(sdir+TOCFILE);
	fread(sdir+"mathjax"+inext,&mathjax,'s');
    if (isint(tocf)) oxrunerror("input file "+sdir+TOCFILE+" failed to open");
    sect = new titlepage();
    decl s;
    for(s =0; s<sizeof(fm); ++s)
       if (puboption>=fm[s][MinLev]) {
        fm[s][fptr] = fopen(bdir+fm[s][fmname]+outext,"w");
        if (isint(fm[s][fptr])) oxrunerror("output file "+bdir+fm[s][fmname]+outext+" failed to open");
        printheader(fm[s][fptr],bkvals[BOOKTITLE]);
        if (!s)
            fprintln(fm[s][fptr],"<div class=\"toc\"\">\n<h3>",fm[s][fmtitle],"</h3>\n<details open>"); //<h3>",fm[s][fmtitle],"</h3>
        else
            fprintln(fm[s][fptr],"<div>\n<h3>",fm[s][fmtitle],"</h3>\n<OL>\n<div class=\"split\">"); //
        }
    curx = curp = matrix(0);
    sect.title = bkvals[BOOKTITLE];
    contents = {sect};

	readtoc();

	/*add links to front section files.*/
  	decl f;
    decl loc;
  	for (f=1;f<sizeof(fm);++f)
      if (puboption>=fm[f][MinLev]) {
        loc = buildtype==BOOK ? "#"+fm[f][fmname] : fm[f][fmname]+outext;
        fprintln(fm[TOC][fptr],"<LI><a href=\"",loc,"\" target=\"content\">",fm[f][fmtitle],"</a></LI>");
        }
  	fprintln(fm[TOC][fptr],"</details></OL></div></body></html>");
  	fclose(fm[TOC][fptr]); fm[TOC][fptr] = 0;

	/*Create All builds of the book*/
	htoc = 0;
	for (buildtype=OUTTYPES-1;buildtype>=0;--buildtype) {
	  	fign[] = 0;   // reset figure numbers
    	exsec = 0;
		htoc = buildtype==BOOK;
		if (htoc) {
			htoc = fopen(bdir+"book"+outext,"w");
			printheader(htoc,bkvals[BOOKTITLE]);
			}
        systemcall(sprint("erase /Q ",bdir+prefs[buildtype]+"???"+outext));

		/* build individual sections of the book for this build */
		foreach(s in contents[f]) {
    		if (buildtype==SECTION && isclass(s.myexer)) exsec=s.myexer;
    		if ( (!f||puboption>=PUBLISH) && puboption>=s.minprintlev && (s.notempty||buildtype==SECTION) )
				s->make(htoc);
    		}
		if (buildtype==SECTION)			/* Complete front section files (not including TOC)*/
	  		for (f=TOC+1;f<sizeof(fm);++f)
				if (isfile(fm[f][fptr])) {
				    fprintln(fm[f][fptr],"</div>");
					lend(fm[f][fptr],0);
        			fprintln(fm[f][fptr],"</div></body></html>");
        			fclose(fm[f][fptr]);
        		fm[f][fptr] = 0;
        		}
		else if (isfile(htoc)) {
		  	lend(htoc,0);
			fprintln(htoc,"</body></html>"); //mreplace(footer,{ {"%prev%",""},{"%next%",""}}));
  			fclose(htoc);
			}
 		println("pass ",prefs[buildtype]," done");
		}

  }
