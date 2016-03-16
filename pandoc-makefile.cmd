@echo off
set /p mdfile="Markdown file: "
set /p outfile="Output file (and directory): "
pandoc -s -S %mdfile% --filter pandoc-citeproc ^
--reference-docx=draft_binary~/ref.docx -o %outfile% --mathjax 
pause

start %outfile%