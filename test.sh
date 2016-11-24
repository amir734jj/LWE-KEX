#!/bin/bash

echo "Regev KEX (not recommended to use, result key may not match):"
sage Regev.sage
echo
echo "Ding KEX (not recommended to use, result key is biased):"
sage Ding.sage
echo
echo -e "Peikert KEX (recommended to use, easy to implement):"
sage Peikert.sage
echo
echo -e "newHope KEX (recommended to use but difficult to implement):"
sage newHope.sage
