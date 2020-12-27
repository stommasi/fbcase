# fbcase - change the case style in FreeBasic files

# FreeBasic reserves a lot of words for its built-in procedures and operations,
# so some people like to distinguish these words from their own variables and
# procedures either by capitalizing or uppercasing the reserved words. This
# program formats the whole file at once in either of three case styles: capital,
# uppercase, or lowercase.

BEGIN {
	# Style can be "UPPER", "LOWER", or "CAPITAL".
	style = "LOWER"

	syntax = "\
		abs abstract access acos add alias allocate alpha and andalso any \
		append as asc asin asm assert assertwarn atan2 atn \
		base beep bin binary bit bitreset bitset bload boolean bsave byref byte byval \
		call callocate case cast cbool cbyte cdbl cdecl chain chdir chr cint circle \
		class clear clng clngint close cls color command common condbroadcast \
		condcreate conddestroy condsignal condwait const constructor continue cos cptr \
		cshort csign csng csrlin cubyte cuint culng culngint cunsg curdir cushort custom \
		cva_arg cva_copy cva_end cva_list cva_start cvd cvi cvl cvlongint cvs cvshort \
		data date dateadd datediff datepart dateserial datevalue day deallocate declare \
		defbyte defdbl defined defint deflng deflongint defshort defsng defstr defvbyte \
		defvint defvlongint defvshort delete destructor dim dir do double draw dylibfree \
		dylibload dylibsymbol \
		else elseif encoding end enum environ eof eqv erase erfn erl ermn err error event \
		exec exepath exit exp export extends extern \
		false fb_memcopy fb_memcopyclear fb_memmove fbarray field fileattr filecopy \
		filedatetime fileexists fileflush filelen fileseteof fix flip for format \
		frac fre freefile function \
		get getjoystick getkey getmouse gosub goto \
		hex hibyte hiword hour \
		if iif imageconvertrow imagecreate imagedestroy imageinfo imp implements \
		import inkey inp input instr instrrev int integer is isdate isredirected \
		kill \
		lbound lcase left len let lib line lobyte loc local locate lock lof log long \
		longint loop loword lpos lprint lset ltrim \
		mid minute mkd mkdir mki mkl mklongint mks mkshort mod month monthname multikey \
		mutexcreate mutexdestroy mutexlock mutexunlock \
		naked name namespace new next not now \
		object oct offsetof on once open operator option or orelse out \
		output overload override \
		paint palette pascal pcopy peek pmap point pointcoord pointer poke pos \
		preserve preset print private procptr property protected pset ptr public put \
		random randomize read reallocate redim rem reset restore resume return \
		rgb rgba right rmdir rnd rset rtrim run \
		sadd scope screen screencopy screencontrol screenevent screenglproc \
		screeninfo screenlist screenlock screenptr screenres screenset screensync \
		screenunlock second seek select setdate setenviron setmouse settime sgn shared \
		shell shl short shr sin single sizeof sleep space spc sqr static stdcall step \
		stick stop str strig string strptr sub swap system \
		tab tan then this threadcall threadcreate threaddetach threadself threadwait \
		time timer timeserial timevalue to trans trim true type \
		ubound ubyte ucase uinteger ulong ulongint union unlock unsigned until ushort using \
		va_arg va_first va_next val vallng valint valuint valulng var varptr view virtual \
		wait wbin wchr weekday weekdayname wend while whex width window windowtitle \
		winput with woct write wspace wstr wstring \
		xor \
		year \
		zstring \
	"

	split(syntax, synarray)
}

function isValid(str, pos, len) {
	# Members of user-defined types do not share a namespace with FB keywords.
	if (substr(str, pos - 2, 2) == "->") {
		return 0
	}

	# Not a keyword if preceded by a legitimate variable character...
	if (pos > 1 && substr(str, pos - 1, 1) ~ /[a-zA-Z0-9_]/) {
		return 0
	}

	# ... or followed by one.
	if (pos < length(str) - (len - 1) && substr(str, pos + len, 1) ~ /[a-zA-Z0-9_]/) {
		return 0
	}

	return 1
}

{
	# Inline assembly is left alone since it has its own syntax.
	if (asm == 1) {
		if (tolower($1) == "end" && tolower($2) == "asm") {
			asm = 0
		} else {
			print
			next
		}
	}

	for (kw in synarray) {
		s = $0
		len = length(synarray[kw])

		p = 1
		delete plist

		while (i = index(tolower(s), synarray[kw])) {
			p += i - 1

			if (isValid($0, p, len)) {
				plist[p] = ""
			}

			p += len

			s = substr(s, i + len)
		}

		for (i in plist) {
			repl = substr($0, i, len)

			if (style == "UPPER") {
				repl = toupper(repl)
			} else if (style == "LOWER") {
				repl = tolower(repl)
			} else if (style == "CAPITAL") {
				repl = toupper(substr(repl, 1, 1)) tolower(substr(repl, 2))
			}

			pre = substr($0, 1, i - 1)
			post = substr($0, i + len)

			$0 = pre repl post
		}
	}

	if (tolower($1) == "asm") {
		asm = 1
	}

	print
}
