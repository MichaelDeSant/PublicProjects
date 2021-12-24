##segmentation


from torchvision import models
fcn = models.segmentation.fcn_resnet101(pretrained=True).eval()
dlab = models.segmentation.deeplabv3_resnet101(pretrained=1).eval()
LRA = models.segmentation.lraspp_mobilenet_v3_large(pretrained=True).eval()

from PIL import Image
import matplotlib.pyplot as plt
import torch

img = Image.open('Goalie2.jpg')
plt.imshow(img); plt.show()


# Apply the transformations needed
import torchvision.transforms as T

trf = T.Compose([T.Resize(256),
                 T.ToTensor(), 
                 T.Normalize(mean = [0.485, 0.456, 0.406], 
                             std = [0.229, 0.224, 0.225])])
                             
                             


inp = trf(img).unsqueeze(0)

# Pass the input through the net
out = fcn(inp)['out']
print (out.shape)


import numpy as np
om = torch.argmax(out.squeeze(), dim=0).detach().cpu().numpy()
print (om.shape)
print (np.unique(om))


# Define the helper function
def decode_segmap(image, nc=21):
  
  label_colors = np.array([(0, 0, 0),  # 0=background
               # 1=aeroplane, 2=bicycle, 3=bird, 4=boat, 5=bottle
               (128, 0, 0), (0, 128, 0), (128, 128, 0), (0, 0, 128), (128, 0, 128),
               # 6=bus, 7=car, 8=cat, 9=chair, 10=cow
               (0, 128, 128), (128, 128, 128), (64, 0, 0), (192, 0, 0), (64, 128, 0),
               # 11=dining table, 12=dog, 13=horse, 14=motorbike, 15=person
               (192, 128, 0), (64, 0, 128), (192, 0, 128), (64, 128, 128), (192, 128, 128),
               # 16=potted plant, 17=sheep, 18=sofa, 19=train, 20=tv/monitor
               (0, 64, 0), (128, 64, 0), (0, 192, 0), (128, 192, 0), (0, 64, 128)])

  r = np.zeros_like(image).astype(np.uint8)
  g = np.zeros_like(image).astype(np.uint8)
  b = np.zeros_like(image).astype(np.uint8)
  
  for l in range(0, nc):
    idx = image == l
    r[idx] = label_colors[l, 0]
    g[idx] = label_colors[l, 1]
    b[idx] = label_colors[l, 2]
    
  rgb = np.stack([r, g, b], axis=2)
  return rgb

rgb = decode_segmap(om)
plt.imshow(rgb); plt.savefig('Seg2FCN.jpg', dpi=300); plt.show()



import time

###Infertime function on input image
def infer_time(net, path='Hockey1.jpg', dev='cuda'):
  img = Image.open(path)
  trf = T.Compose([T.Resize(256), 
                   T.CenterCrop(256), 
                   T.ToTensor(), 
                   T.Normalize(mean = [0.485, 0.456, 0.406], 
                               std = [0.229, 0.224, 0.225])])
  
  inp = trf(img).unsqueeze(0).to(dev)
  
  st = time.time()
  out1 = net.to(dev)(inp)
  et = time.time()
  
  return et - st


####CPU Inference Function
def CPU_Inference():
  avg_over = 100
  fcn_infer_time_list_cpu = [infer_time(fcn, dev='cpu') for _ in range(avg_over)]
  fcn_infer_time_avg_cpu = sum(fcn_infer_time_list_cpu) / avg_over
  dlab_infer_time_list_cpu = [infer_time(dlab, dev='cpu') for _ in range(avg_over)]
  dlab_infer_time_avg_cpu = sum(dlab_infer_time_list_cpu) / avg_over
  print ('The Average Inference time on FCN is(cpu):     {:.2f}s'.format(fcn_infer_time_avg_cpu))
  print ('The Average Inference time on DeepLab is(cpu): {:.2f}s'.format(dlab_infer_time_avg_cpu))

###GPU Inference Function
def GPU_Inference():
  avg_over = 100
  fcn_infer_time_list_gpu = [infer_time(fcn) for _ in range(avg_over)]
  fcn_infer_time_avg_gpu = sum(fcn_infer_time_list_gpu) / avg_over
  dlab_infer_time_list_gpu = [infer_time(dlab) for _ in range(avg_over)]
  dlab_infer_time_avg_gpu = sum(dlab_infer_time_list_gpu) / avg_over
  print ('The Average Inference time on FCN is(gpu):     {:.3f}s'.format(fcn_infer_time_avg_gpu))
  print ('The Average Inference time on DeepLab is(gpu): {:.3f}s'.format(dlab_infer_time_avg_gpu))

#CPU_Inference()

#GPU_Inference()