if [ -d 'huang_wordemb' ]; then
  echo "Directory already exist"
else
  wget http://www-nlp.stanford.edu/~ehhuang/wordrep.zip;
  unzip wordrep.zip;
  rm wordrep.zip;
  mv release huang_wordemb;
fi
