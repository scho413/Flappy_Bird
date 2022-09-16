t = Mask_maker("flappy.png", "flappy.mif")
function t = Mask_maker(image_name, text_name)
% Read a RGB image file and write to YCbCr text files
% for Y, Cb, and Cr channels
% ---------------------------
% The format of text file:
% W  ; Width size
% H  ; Height size
% N  ; number of frame
% XXXXXX ; YCbCr data in Hex
% XXXXXX
% .....
% ---------------------------
im = imread(image_name);
im = im2uint8(rgb2ycbcr(im));
fid = fopen(text_name,'W'); 
imsize = size(im);
count = 0;
if (fid)     
    %% Write the RGB data
    fprintf(fid,'WIDTH = 8;\n');
    fprintf(fid,'DEPTH = %d;\n',imsize(1)*imsize(2));
    fprintf(fid,'ADDRESS_RADIX = OCT;\n');
    fprintf(fid,'DATA_RADIX = BIN;\n');
    fprintf(fid,'CONTENT BEGIN\n\n');
    for i=1:imsize(1)
       for j=1:imsize(2)
          if (mod(count, 16) == 6 || count == 0)      fprintf(fid,'%d\t: ',count);
          end
          if (count >= 6 && count <= 261)
            if(im(i,j,1) >= 127)         fprintf(fid,'1');   
            else                         fprintf(fid,'0');
            end
          end
          count = count + 1;
          if (mod(count, 16) == 6)      fprintf(fid,';\n');
          end
          
       end    
    end 
    fprintf(fid,'END;\n');
    fclose(fid);
    t = 0; % successful
	
else
    t = 1; % error
end
end