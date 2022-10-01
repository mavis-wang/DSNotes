""" 2020.03
author: mavis wang
"""

import cv2 as cv
import matplotlib.pyplot as plt
import pickle
import torch
import shutil
import numpy as np
import pandas as pd
# from torch_snippets import *

import torchvision.io
from IPython.core.display import Video
from moviepy.editor import *
import moviepy.video.fx.all as vfx
from moviepy.video.fx.all import crop, resize
import ffmpeg

import json
import argparse
import pickle
import random
import os

from tqdm import tqdm
import subprocess


def processVideo(videoPath, start_time, end_time):
    # main DIRs
    if not os.path.exists(input_DIR):
        os.mkdir(input_DIR)
    if not os.path.exists(data_processed_DIR):
        os.mkdir(data_processed_DIR)
    if not os.path.exists(data_raw_DIR):
        os.mkdir(data_raw_DIR)
    if not os.path.exists(results_DIR):
        os.mkdir(results_DIR)
    
    clip = VideoFileClip(videoPath, audio=False).subclip(start_time,end_time)
    clip_resize = resize(clip, width=220)
    newclip = crop(clip_resize, x_center=100, y_center= 130, width=192, height=256)
    newclip.write_videofile(data_processed_DIR + 'tryOnVideo.mp4', fps=10)
    newclip.write_videofile(input_DIR + 'tryOnVideo.mp4', fps=10)    
    
    processedVideo = data_processed_DIR + 'tryOnVideo.mp4'
    savePath = img_frames_DIR

    if not os.path.exists(img_frames_DIR):
        os.mkdir(img_frames_DIR)
    cap = cv.VideoCapture(processedVideo)
    hasFrame, frame = cap.read()
    count = 0
    current_frame = 0
    while hasFrame:  
        hasFrame, frame = cap.read()
        if hasFrame:
            fileName = str(count).zfill(6) + '_0.jpg'
            cv.imwrite(savePath+fileName, frame)
        count +=1
        current_frame += 1
    cap.release()
    cv.destroyAllWindows()
    return processedVideo

            
def getKPVideo(videoPath, start_time, end_time):
    
    # input video
    processed_Video = processVideo(videoPath, start_time, end_time)
    
    kps, kp_overlay = getKP(processed_Video)
    kp_frames_BGR = [cv.cvtColor(frame, cv.COLOR_BGR2RGB) for frame in kp_overlay]
    
    # to torch
    kp_frames_num_to_torch = [torch.from_numpy(i) for i in kp_frames_BGR]
    
    # to torchvision vframe
    kp_frames_torch = torch.stack(kp_frames_num_to_torch, dim=0)
    
    torchvision.io.write_video(os.path.join(results_DIR,'out_kpVideo.mp4'), kp_frames_torch, fps=10)
    kpvideo = os.path.join(results_DIR,'out_kpVideo.mp4')
    
    return (processed_Video, kpvideo)


""" SCHP
"""
def humanParse(filePath = '../lib/humanParsing/parse.py', dataset = 'pascal', model = '../lib/humanParsing/model_Schp_pascal.pth', inputDIR = '../data/processed/image', outputDIR = '../lib/humanParsing/pascal'):
    
    pascalDIR = humanParsingDIR + 'pascal'
    lipDIR = humanParsingDIR + 'lip'
    
    if not os.path.exists(pascalDIR):
        os.mkdir(pascalDIR)
    
    if not os.path.exists(lipDIR):
        os.mkdir(lipDIR)

    # pascal
    subprocess.run(['python3', filePath, 
                    '--dataset', dataset, 
                    '--model-restore', model, 
                    '--input-dir', inputDIR, 
                    '--output-dir', outputDIR])
    # # lip
    # subprocess.run(['python3', filePath, 
    #                 '--dataset', 'lip', 
    #                 '--model-restore', '../lib/humanParsing/model_Schp_lip.pth', 
    #                 '--input-dir', inputDIR, 
    #                 '--output-dir', outputDIR])
    
    
def getImageParse():         
    
    # from
    pascalDIR = humanParsingDIR + 'pascal'
    lipDIR = humanParsingDIR + 'lip' 
    
    
    if not os.path.exists(parsed_img_DIR):
        shutil.copytree(pascalDIR, parsed_img_DIR)
    else:
        shutil.rmtree(parsed_img_DIR)
        shutil.copytree(pascalDIR, parsed_img_DIR)
    
    if not os.path.exists(parsed_img_lip_DIR):
        shutil.copytree(lipDIR, parsed_img_lip_DIR)
    else:
        shutil.rmtree(parsed_img_lip_DIR)
        shutil.copytree(lipDIR, parsed_img_lip_DIR)


def getImageMask(img_frames_DIR, parsed_img_DIR, image_mask_DIR):
    
    # copy imgs from parsed folder to mask folder
    if not os.path.exists(image_mask_DIR):
        shutil.copytree(parsed_img_DIR, image_mask_DIR)
    else:
        shutil.rmtree(image_mask_DIR)
        shutil.copytree(parsed_img_DIR, image_mask_DIR)
        
    img_mask = list(np.sort(os.listdir(image_mask_DIR)))
    img_frame = list(np.sort(os.listdir(img_frames_DIR)))
    
    for im in img_mask:
        imPath = os.path.join(image_mask_DIR, im)
        framePath = os.path.join(img_frames_DIR, im.replace('.png','.jpg'))
        
        if imPath.endswith('.png') or framePath.endswith('.jpg'):
            im_parse = cv.imread(imPath, cv.IMREAD_GRAYSCALE)
            img = cv.imread(framePath, cv.IMREAD_GRAYSCALE)
            
            (_,parsed) = cv.threshold(im_parse,0, 255, cv.THRESH_BINARY)

            gray = cv.bitwise_not(img, cv.COLOR_BGR2GRAY)
            (_,image) = cv.threshold(gray,65, 255, cv.THRESH_BINARY)
            mask = parsed + image
            cv.imwrite(imPath, mask)
    
    return image_mask_DIR


def getImageParseNew(parsed_img_DIR ,img_parse_new_DIR):
    if not os.path.exists(img_parse_new_DIR):
        shutil.copytree(parsed_img_DIR, img_parse_new_DIR)
    else:
        shutil.rmtree(img_parse_new_DIR)
        shutil.copytree(parsed_img_DIR, img_parse_new_DIR)
        
    img_parse_new = list(np.sort(os.listdir(img_parse_new_DIR)))
    
    for im in img_parse_new:
        imPath = os.path.join(img_parse_new_DIR, im)
        
        if imPath.endswith('.png'):
            img = cv.imread(imPath,cv.IMREAD_GRAYSCALE)
            for i, v in np.ndenumerate(img):
                if v == 76:  #. hair
                    img[i[0]][i[1]] = 2
                elif v == 29:  #. head
                    img[i[0]][i[1]] = 13
                elif v == 140 or v == 178:  #. arms
                    img[i[0]][i[1]] = 14
                elif v == 126:
                    img[i[0]][i[1]] = 5
                elif v == 59 or v == 210:   #. legs
                    img[i[0]][i[1]] = 16
                elif v == 156:
                    img[i[0]][i[1]] = 20
                    
            cv.imwrite(imPath, img)


def processCloth(raw_cloth_DIR, cloth_DIR, cloth_mask_DIR):

    # raw -> process
    if os.path.exists(cloth_DIR):
        shutil.rmtree(cloth_DIR)
    shutil.copytree(raw_cloth_DIR, cloth_DIR)
    
    frameWidth = 192
    frameHeight = 256

    files = os.listdir(cloth_DIR)    
    for file in files:
        if file.endswith('.jpg'): 
            fPath = os.path.join(cloth_DIR, file)            
            im = cv.imread(fPath, cv.IMREAD_UNCHANGED)
            im_resized = cv.resize(im, (frameWidth,frameHeight), interpolation = cv.INTER_AREA) 
            cv.imwrite(fPath, im_resized)            
    
    count = 0  
    for file in files:
        if file.endswith('.jpg'): 
            fPath = os.path.join(cloth_DIR, file)
            fileName = str(count).zfill(6) + '_2.jpg'
            os.rename(fPath,cloth_DIR+fileName)
            count += 1
    
    """ cloth masks """
    if os.path.exists(cloth_mask_DIR):
        shutil.rmtree(cloth_mask_DIR) #. rm if exist
    shutil.copytree(cloth_DIR, cloth_mask_DIR)
    files = os.listdir(cloth_mask_DIR)
    for file in files:
        f = os.path.join(cloth_mask_DIR, file)
        if f.endswith('.jpg'):
            im = cv.imread(f, cv.IMREAD_UNCHANGED)
            im = cv.bitwise_not(im)
            gray = cv.cvtColor(im, cv.COLOR_BGR2GRAY)
            (thresh, blackAndWhiteImage) = cv.threshold(gray, 90, 255, cv.THRESH_BINARY) 
            cv.imwrite(f, blackAndWhiteImage)
            

def randomTestPairsTxt(img_frames_DIR, cloth_DIR):
    
    images = np.sort(os.listdir(img_frames_DIR))
    images = [img for img in images if img.endswith('.jpg')]
    
    clothes = np.sort(os.listdir(cloth_DIR))
    clothes = [c for c in clothes if c.endswith('.jpg')]
    
    c_randIndex = random.randint(0,len(clothes)-1)
    cloth_rand = [str(clothes[c_randIndex])]
    
    if not os.path.exists(input_cloth_DIR):
        os.mkdir(input_cloth_DIR)
    
    # get clothID.jpg
    clothPath = cloth_DIR + cloth_rand[0]
    cloth_gen = cv.imread(clothPath)
    cv.imwrite(input_cloth_DIR + cloth_rand[0], cloth_gen)
    
    # create same number of clothes as frames
    test_pairs_df = pd.DataFrame(images)
    test_pairs_df['c'] = cloth_rand * len(images)
    test_pairs_df.columns = ['image', 'cloth']
    
    test_pairs_df.to_csv(r'../data/input/testPairs.txt', header=None, index=None, sep=' ', mode='w')
    test_pairs_df.to_csv(cpVtonPlusDIR +'data/testPairs.txt', header=None, index=None, sep=' ', mode='w')
       
    return test_pairs_df
    
def testPairsTxt(clothID, img_frames_DIR, cloth_DIR): 
    
    idx = clothID

    images = np.sort(os.listdir(img_frames_DIR))
    images = [img for img in images if img.endswith('.jpg')]

    clothes = np.sort(os.listdir(cloth_DIR))
    clothes = [c for c in clothes if c.endswith('.jpg')]

    if not os.path.exists(input_cloth_DIR):
        os.mkdir(input_cloth_DIR)

    # make same length as frames 
    cloth_list = [clothes[idx]]*len(images)

    test_pairs_df = pd.DataFrame(images)
    test_pairs_df['2'] = cloth_list

    # save
    test_pairs_df.to_csv(input_DIR +'testPairs.txt', header=None, index=None, sep=' ', mode='w')
    test_pairs_df.to_csv(cpVtonPlusDIR +'data/testPairs.txt', header=None, index=None, sep=' ', mode='w')
            
    return test_pairs_df


def tryOnInputGen(cpVtonPlusDIR):
    testDataDIR = cpVtonPlusDIR + 'data/test/'
    
    test_img_frames_DIR = testDataDIR + 'image/'
    test_cloth_DIR = testDataDIR + 'cloth/'
    test_parsed_img_DIR = testDataDIR + 'image-parse/'
    test_image_mask_DIR = testDataDIR + 'image-mask/'
    test_img_parse_new_DIR = testDataDIR + 'image-parse-new/'
    test_cloth_mask_DIR = testDataDIR + 'cloth-mask/'
    test_pose_DIR = testDataDIR + 'pose/'


    if not os.path.exists(test_img_frames_DIR):
        shutil.copytree(img_frames_DIR, test_img_frames_DIR)
    else:
        shutil.rmtree(test_img_frames_DIR)
        shutil.copytree(img_frames_DIR, test_img_frames_DIR)

    if not os.path.exists(test_cloth_DIR):
        shutil.copytree(cloth_DIR, test_cloth_DIR)
    else:
        shutil.rmtree(test_cloth_DIR)
        shutil.copytree(cloth_DIR, test_cloth_DIR)

    if not os.path.exists(test_parsed_img_DIR):
        shutil.copytree(parsed_img_DIR, test_parsed_img_DIR)
    else:
        shutil.rmtree(test_parsed_img_DIR)
        shutil.copytree(parsed_img_DIR, test_parsed_img_DIR)

    if not os.path.exists(test_image_mask_DIR):
        shutil.copytree(image_mask_DIR, test_image_mask_DIR)
    else:
        shutil.rmtree(test_image_mask_DIR)
        shutil.copytree(image_mask_DIR, test_image_mask_DIR)

    if not os.path.exists(test_img_parse_new_DIR):
        shutil.copytree(img_parse_new_DIR, test_img_parse_new_DIR)
    else:
        shutil.rmtree(test_img_parse_new_DIR)
        shutil.copytree(img_parse_new_DIR, test_img_parse_new_DIR)

    if not os.path.exists(test_cloth_mask_DIR):
        shutil.copytree(cloth_mask_DIR, test_cloth_mask_DIR)
    else:
        shutil.rmtree(test_cloth_mask_DIR)
        shutil.copytree(cloth_mask_DIR, test_cloth_mask_DIR)

    if not os.path.exists(test_pose_DIR):
        shutil.copytree(pose_DIR, test_pose_DIR)
    else:
        shutil.rmtree(test_pose_DIR)
        shutil.copytree(pose_DIR, test_pose_DIR)
        

""" CP-VTON-PLUS
"""
    
# transfer GMM outputs to TOM inputs
def moveGMMoutput(src_warp_cloth, src_warp_mask, dest_warp_cloth, dest_warp_mask):

    if os.path.exists(dest_warp_cloth):
        shutil.rmtree(dest_warp_cloth)
    if os.path.exists(dest_warp_mask):
        shutil.rmtree(dest_warp_mask)

    shutil.copytree(src_warp_cloth, dest_warp_cloth)
    shutil.copytree(src_warp_mask, dest_warp_mask)


def getTryOnVideo(out_tryOn_DIR, clothID=0):
    
    if not os.path.exists(out_tryOnimg_frames_DIR):
        shutil.copytree(out_tryOn_DIR, out_tryOnimg_frames_DIR)
    else:
        shutil.rmtree(out_tryOnimg_frames_DIR)
        shutil.copytree(out_tryOn_DIR, out_tryOnimg_frames_DIR)  
        
    frames = []
    for filename in os.listdir(out_tryOn_DIR):
        f = os.path.join(out_tryOn_DIR, filename)

        if f.endswith('.jpg'):
            frames.append(f)
    
    # final try-on video output name = out_tryOnVideo_clothID.mp4
    savePath = results_DIR + 'out_tryOnVideo_'+str(clothID)+'.mp4'
    
    frames = list(np.sort(frames))
    clip = ImageSequenceClip(frames, fps = 10) 
    clip.write_videofile(savePath)
    
    out_tryOnVideo = savePath
    
    return out_tryOnVideo


""" Visualizer
"""

def showColabVideo(file_name, width=384, height=512):
    
    import io
    import base64
    from IPython.display import HTML
    
    video_encoded = base64.b64encode(io.open(file_name, 'rb').read())
    return HTML(data='''<video width="{0}" height="{1}" alt="test" controls>
                        <source src="data:video/mp4;base64,{2}" type="video/mp4" />
                      </video>'''.format(width, height, video_encoded.decode('ascii')))


def framesToVideo(frames_DIR, outVideoPath):
    import os, numpy as np
    outfile = outVideoPath
    
    frames = []
    for filename in os.listdir(frames_DIR):
        if filename.endswith('.png'):
            f = os.path.join(frames_DIR, filename)
            frames.append(f)
    
    print(f'frames count: {len(frames)}')
    
    # sort by filenames
    frames = list(np.sort(frames))
    clip = ImageSequenceClip(frames, fps=28) 
    
    clip.write_videofile(outfile)
    
    out_tryOnVideo = outfile
    
    return out_tryOnVideo