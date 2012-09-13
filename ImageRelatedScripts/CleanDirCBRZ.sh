#!/bin/bash
#will find and remove all cbrz files starting from the present directory.
find . -name *.[Cc][Bb][RrZz] -print0 | xargs -0 -I {} rm {}
