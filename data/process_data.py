import glob
import os
import numpy as np
import tqdm
import math
import sys

if __name__ == '__main__':
    np.seterr(all='raise')
    # Get the endianness of the system
    endianness = sys.byteorder
    print(endianness)
    ROOT = os.path.dirname(__file__)
    all_paths = glob.glob(os.path.join(ROOT, 'data/*.xyz'))
    all_paths_relative = [os.path.split(x)[1] for x in all_paths]
    all_coords = [(int(x[-13:-9]),int(x[-8:-4])) for x in all_paths_relative]
    block_length = len(all_coords)
    assert block_length==43590
    all_coords = np.array(all_coords)
    # print(all_coords[678])
    # Max x: Eastmost
    # Min x: Westmost
    # Max y: Northmost
    # Min y: Southmost
    max_x = all_coords[:,0].max()
    min_x = all_coords[:,0].min()
    max_y = all_coords[:,1].max()
    min_y = all_coords[:,1].min()
    len_x = int(max_x - min_x + 1)
    len_y = int(max_y - min_y + 1)
    origin_x = int(min_x*1000 + 1)
    origin_y = int(min_y*1000 + 1)
    print(max_x, min_x, max_y, min_y)
    # Resolution is represented in the unit of meter
    resolution = 4
    sample_gap = int(resolution/2)
    block_side_length = int(500/sample_gap)
    block_size = block_side_length * block_side_length
    mask = np.zeros(500*500,dtype=bool)
    indices = -np.ones(500*500,dtype = int)
    for i in range(500):
        for j in range(500):
            x = j*2+1
            y = 1000 - i*2 - 1
            if (not (x - 1)%resolution) and (not (y - 1)%resolution):
                mask[j+i*500] = True
                indices[j+i*500] = (x - 1)//resolution*block_side_length+(y-1)//resolution
    indices = indices[mask]
    mask = np.arange(500*500)[mask]
    assert (indices!=-1).all()
    # If scale*max_height<65535, then the scale is valid. Scale has to be integer.
    scale = 14 

    # This matrix is used to store the indices of blocks which have sizes of 1 square km
    # non-negative value means the index, -1 means that block does not exist
    index_mat = np.full((len_x, len_y), fill_value = -1, dtype = np.int32)

    # This matrix is used to store the multiplied elevation of each x,y coordinate
    # positive value means elevation*scalar, 0 means that elevation does not exist
    zipped = np.full((block_length,block_size), fill_value = 0, dtype = np.uint16)
    for i,coord in enumerate(tqdm.tqdm(all_coords)):
        filename = os.path.join(ROOT, 'data', f'SWISSALTI3D_2_XYZ_CHLV95_LN02_{coord[0]}_{coord[1]}.xyz')
        index_mat[coord[0]-min_x][coord[1]-min_y] = i
        with open(filename, 'r') as f:
            strings = f.readlines()[1:]
            for j in range(mask.size):
                string = strings[mask[j]]
                elevation = float(string[16:])
                if elevation<0:
                    elevation = 0
                assert elevation<4650 and elevation>=0
                zipped[i][indices[j]] = int(elevation*scale)

    # Here, I need to write down the format of the zipped file
    # Bytes 0~3 int origin_x
    # Bytes 4~7 int origin_y
    # Bytes 8~11 int len_x
    # Bytes 12~15 int len_y
    # Bytes 16~19 int resolution    (should be 4)
    # Bytes 20~23 int scale         (should be 14)
    # Bytes 24~27 int block_length  (should be 43590)
    # Bytes 28~28+len_x*len_y*4 int index_mat
    # Bytes 28+len_x*len_y*4~end unsigned short int[] zipped
    with open(os.path.join(ROOT,'zipped.dat'),'wb') as f:
        f.write(origin_x.to_bytes(4,endianness))
        f.write(origin_y.to_bytes(4,endianness))
        f.write(len_x.to_bytes(4,endianness))
        f.write(len_y.to_bytes(4,endianness))
        f.write(resolution.to_bytes(4,endianness))
        f.write(scale.to_bytes(4,endianness))
        f.write(int(block_length).to_bytes(4,endianness))
        f.write(index_mat.tobytes())
        f.write(zipped.tobytes())
