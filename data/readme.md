# Guide to preprocess data
Attention:

This guide is used to preprocess data set from scratch, please keep at least 300GB free space of the disk holding this directory before starting.

If you are running the script by git bash under Windows OS, you can run ```killall.sh``` to kill all scripts running by git bash.

You should first go under current folder(```data\```) to start preprocessing.

- Run ```paralell_download.sh```. This step will download ~50GB data from SwissAlti3d server and the time taken will be decided by the speed of the net
- Run ```check_zip.sh``` to check whether all data are downloaded properly. There should be no warning or error showing up. If an error is encountered, delete all related zip file and rerun last step to download zip files which are missing. This step will take several minutes if running on SSD. Runing on HDD will take longer time.
- Run ```unzip_data.sh``` to unzip all data downloaded into the folder ```data\data\```. This step may take dozens of minute if running on SSD. Runing on HDD will take longer time.
- Run ```process_data.py``` to generate preprocessed data set ```zipped.dat```. This step will take about an hour if running on SSD.
- Run ```clear_all.sh``` to clear all data and temp file except for the final prepocessed data set ```zipped.dat```. Please make sure that every step above are runned correctly before deleting!