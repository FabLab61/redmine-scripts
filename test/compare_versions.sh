#!/bin/bash


compareVersions ()
{
echo $VER_1 $VER2 | \
awk '{ split($1, a, ".");
       split($2, b, ".");
       for (i = 1; i <= 3; i++)
           if (a[i] < b[i]) {
               x =-1;
               break;
           } else if (a[i] > b[i]) {
               x = 1;
               break;
           }
       print x;
     }'
}
compareVersions