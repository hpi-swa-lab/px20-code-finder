#!/bin/sh

DOWNLOAD_DIR='python_dependencies_download'
DEPENDENCY_DIR='python_dependencies'
TEMPFILE=temp.tar.gz

mkdir -p $DOWNLOAD_DIR
mkdir -p $DEPENDENCY_DIR

while read package_url; do
  echo "Install $package_url"
  wget -O $TEMPFILE $package_url 
  tar -xzf $TEMPFILE -C $DOWNLOAD_DIR
done <python_requirements.txt

echo "Downloads done!"

for dependency in $DOWNLOAD_DIR/*; do
    dependency_tag=$(basename -- "$dependency")
    dependency_name=${dependency_tag%-*}
    dependency_name=$(echo $dependency_name | tr '[:upper:]' '[:lower:]')
    dependency_path=$dependency/$dependency_name
    if [ -d "$DEPENDENCY_DIR/$dependency_name" ]; then
        echo "$dependency_name is already installed"
    else
        mv $dependency/$dependency_name $DEPENDENCY_DIR
        echo "$dependency_tag installed"
    fi
done

rm -r $DOWNLOAD_DIR
rm $TEMPFILE
