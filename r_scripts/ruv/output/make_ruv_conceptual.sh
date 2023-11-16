#!/usr/bin/bash
pdfjam ruv_conceptual_1.pdf ruv_conceptual_2.pdf ruv_conceptual_3.pdf ruv_conceptual_4.pdf --nup 1x4 --no-landscape --outfile temp.pdf
pdfcrop temp.pdf
mv temp-crop.pdf ruv_conceptual.pdf
rm temp.pdf
