BOILERPLATE_DIR="/home/lowie/Documents/IIW/S8/HW_SW_Codesign/boilerplate/1_soc/104_crosscompiling/"

cd $1
mkdir src
mkdir target
mkdir build
cp $BOILERPLATE_DIR/Makefile Makefile
cp $BOILERPLATE_DIR/firmware.lds firmware.ids
cp $BOILERPLATE_DIR/src/firmware.c src/firmware.c
cp $BOILERPLATE_DIR/src/start.S src/start.S