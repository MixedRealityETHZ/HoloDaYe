mkdir data
ls swiss*.zip | xargs -I hahaha unzip -n hahaha -d data/
rm swiss*.zip
