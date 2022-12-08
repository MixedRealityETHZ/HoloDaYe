mkdir data
ls swiss*.zip | xargs -I {} -P 0 unzip -n {} -d data/
rm swiss*.zip
