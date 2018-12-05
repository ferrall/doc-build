OX := "C:\Program Files\$(Version)\Ox\bin64\oxl.exe"
OXFLAGS := -DOX7 -v1 -d 
ECHO := echo
CD := dir
COPY := copy
OXDOC := "C:\Program Files (x86)\oxdoc\bin\oxdoc.bat"
SED := "C:\Program Files (x86)\GnuWin32\bin\sed.exe"
ERASE := erase
XMP := .\examples
DOC := .\docs
INC := .

vpath %.ox .
vpath %.h  $(INC)
vpath %.oxh  $(INC)
vpath %.oxo  $(INC)
vpath %.ox.html  $(DOC)

doc-build.oxo : 

%.oxo : %.ox %.h
	$(OX) $(OXFLAGS)-c $<
		
.PHONY : document
document:
	$(OXDOC) -include $(INC) doc-build.ox
