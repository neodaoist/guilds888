for oldname in *
do
  newname=`echo $oldname | sed -e 's/ //g'`
  mv "$oldname" "$newname"
done