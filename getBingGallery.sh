#!/bin/bash
# Download the complete bing.com/gallery and some more pictures from bing.com sources

if [ -z $(curl -s --head www.bing.com | head -n1 | cut -d ' ' -f2) ]; then
    echo "bing.com is not reachable."
    exit 1
fi

#Define some variables
varPicURL="http://az619519.vo.msecnd.net/files/ http://az608707.vo.msecnd.net/files/ http://az619822.vo.msecnd.net/files/ www.bing.com/az/hprichbg/rb/"
varPicRes="1920x1200 1920x1080 1080x1920 1366x768 958x512"

#Create the folder structure for the image files
mkdir -v -p ./BingGalleryPictures
cd ./BingGalleryPictures
for i in ${varPicRes}; do
    if [ ! -d ${i} ]; then
        if [ $(curl -s --head "http://www.bing.com/gallery/home/browsedata?z=0" | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
            varPicName=$(curl -s "http://www.bing.com/gallery/home/browsedata?z=0" | tr "]" "\n" | grep imageNames | tr "[" "\n" | grep -v imageNames | tr "," "\n" | tr -d "\"")
            if [ -n "${varPicName}" ]; then
                for j in ${varPicName}; do
                    for k in ${varPicURL}; do
                        if [ $(curl -s --head ${k}${j}_${i}.jpg | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
                            mkdir -v -p ${i}
                            break
                        fi
                    done
                    if [ -d ${i} ]; then
                        break
                    fi
                done
            fi
        fi
        if [ $(curl -s --head "http://www.bing.com/HPImageArchive.aspx" | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
            for j in $(seq 999); do
                varPicNameL=$(curl -s "http://www.bing.com/HPImageArchive.aspx?format=js&idx=$((${j}-3))&n=8&mkt=en-US" | tr : "\n" | tr "\"" "\n" | grep .jpg)
                if [ -z "${varPicNameL}" ]; then
                    varPicSeq=$((${j} + 1))
                    continue
                fi
                if [ ${j} -gt $varPicSeq ]; then
                    varPicNameL=$(echo -e "${varPicNameL}" | tail -n1)
                    if [ "${varPicPre}" == "${varPicNameL}" ]; then
                        break
                    fi
                fi
                for k in ${varPicNameL}; do
                    if [ $(curl -s --head www.bing.com/${k}_${i}.jpg | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
                        mkdir -v -p ${i}
                        break
                    fi
                done
                if [ -d ${i} ]; then
                    break
                fi
                varPicPre=${k}
            done
        fi
    fi
    if [ ! -d ROW_${i} ]; then
        if [ $(curl -s --head "http://az517271.vo.msecnd.net/TodayImageService.svc/HPImageArchive?mkt=en-ww&idx=0" | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
            varPicPre=""
            for j in $(seq 999); do
                varPicNameL=$(curl -s "http://az517271.vo.msecnd.net/TodayImageService.svc/HPImageArchive?mkt=en-ww&idx=$((${j}-1))" | tr "<" "\n" | grep fullImageUrl | tr ">" "\n" | tr ' ' "\n" | grep jpg | cut -d "_" -f1,2)
                if [ -z "${varPicNameL}" ]; then
                    break
                fi
                if [ "${varPicPre}" == "${varPicNameL}" ]; then
                    break
                fi
                if [ $(curl -s --head ${varPicNameL}_${i}.jpg | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
                    mkdir -v -p ROW_${i}
                    break
                fi
                varPicPre=${varPicNameL}
            done
        fi
    fi
done

#If there was an error, delete the last picture
if [ -f lastpicture ]; then
    if [ -z "$(cat lastpicture | grep _ROW)" ]; then
        for i in ${varPicRes}; do
            if [ -f ${i}/$(cat lastpicture)_${i}.jpg ]; then
                rm -v ${i}/$(cat lastpicture)_${i}.jpg
            fi
        done
    else
        for i in ${varPicRes}; do
            if [ -f ROW_${i}/$(cat lastpicture)_${i}.jpg ]; then
                rm -v ROW_${i}/$(cat lastpicture)_${i}.jpg
            fi
        done
    fi
    rm lastpicture
fi

#Get all the pictures from bing.com/gallery
if [ $(curl -s --head "http://www.bing.com/gallery/home/browsedata?z=0" | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
    varPicName=$(curl -s "http://www.bing.com/gallery/home/browsedata?z=0" | tr "]" "\n" | grep imageNames | tr "[" "\n" | grep -v imageNames | tr "," "\n" | tr -d "\"")
    if [ -n "${varPicName}" ]; then
        for i in ${varPicName}; do
            if [[ ! -f 1920x1200/${i}_1920x1200.jpg && ! -f 1920x1080/${i}_1920x1080.jpg && ! -f 1366x768/${i}_1366x768.jpg && ! -f 958x512/${i}_958x512.jpg ]]; then
                echo ${i} > lastpicture
                for j in ${varPicRes}; do
                    for k in ${varPicURL}; do
                        if [ -z $(curl -s --head www.bing.com | head -n1 | cut -d ' ' -f2) ]; then
                            echo "bing.com is not reachable."
                            exit 1
                        fi
                        if [ $(curl -s --head ${k}${i}_${j}.jpg | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
                            wget -nv --directory-prefix=${j} ${k}${i}_${j}.jpg
                        fi
                        if [ -f ${j}/${i}_${j}.jpg ]; then
                            break
                        fi
                    done
                done
                if [ -f lastpicture ]; then
                    echo "" > lastpicture
                fi
            fi
        done
    fi
fi

#Get the future, current and past pictures from bing.com
if [ $(curl -s --head "http://www.bing.com/HPImageArchive.aspx" | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
    varPicSeq=1
    for i in $(seq 999); do
        varPicNameL=$(curl -s "http://www.bing.com/HPImageArchive.aspx?format=js&idx=$((${i}-3))&n=8&mkt=en-US" | tr : "\n" | tr "\"" "\n" | grep .jpg | cut -d "_" -f1,2)
        varPicNameS=$(curl -s "http://www.bing.com/HPImageArchive.aspx?format=js&idx=$((${i}-3))&n=8&mkt=en-US" | tr : "\n" | tr "\"" "\n" | tr "/" "\n" | grep .jpg | cut -d "_" -f1,2)
        if [ -z "${varPicNameL}" ]; then
            varPicSeq=$((${i} + 1))
            continue
        fi
        if [ ${i} -gt $varPicSeq ]; then
            varPicNameL=$(echo -e "${varPicNameL}" | tail -n1)
            varPicNameS=$(echo -e "${varPicNameS}" | tail -n1)
            if [ "${varPicPre}" == "${varPicNameL}" ]; then
                break
            fi
        fi
        varCount=0
        for j in ${varPicNameL}; do
            varCount=$((${varCount}+1))
            for k in ${varPicRes}; do
                if [ ! -f ${k}/$(echo -e "${varPicNameS}" | head -n${varCount} | tail -n1)_${k}.jpg ]; then
                    echo -e "${varPicNameS}" | head -n${varCount} | tail -n1 > lastpicture
                    if [ -z $(curl -s --head www.bing.com | head -n1 | cut -d ' ' -f2) ]; then
                        echo "bing.com is not reachable."
                        exit 1
                    fi
                    if [ $(curl -s --head www.bing.com/${j}_${k}.jpg | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
                        wget -nv --directory-prefix=${k} bing.com/${j}_${k}.jpg
                    fi
                    if [ -f lastpicture ]; then
                        echo "" > lastpicture
                    fi
                fi
            done
            varPicPre=${j}
        done
    done
fi

#Get some more pictures by using the Bing Desktop address
if [ $(curl -s --head "http://az517271.vo.msecnd.net/TodayImageService.svc/HPImageArchive?mkt=en-ww&idx=0" | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
    varPicPre=""
    for i in $(seq 999); do
        varPicNameL=$(curl -s "http://az517271.vo.msecnd.net/TodayImageService.svc/HPImageArchive?mkt=en-ww&idx=$((${i}-1))" | tr "<" "\n" | grep fullImageUrl | tr ">" "\n" | tr ' ' "\n" | grep jpg | cut -d "_" -f1,2)
        varPicNameS=$(curl -s "http://az517271.vo.msecnd.net/TodayImageService.svc/HPImageArchive?mkt=en-ww&idx=$((${i}-1))" | tr "<" "\n" | grep fullImageUrl | tr ">" "\n" | tr ' ' "\n" | tr "/" "\n" | grep jpg | cut -d "_" -f1,2)
        if [ -z "${varPicNameL}" ]; then
            break
        fi
        if [ "${varPicPre}" == "${varPicNameS}" ]; then
            break
        fi
        for j in ${varPicRes}; do
            if [ ! -f ROW_${j}/${varPicNameS}_${j}.jpg ]; then
                echo ${varPicNameS} > lastpicture
                if [ -z $(curl -s --head www.bing.com | head -n1 | cut -d ' ' -f2) ]; then
                    echo "bing.com is not reachable."
                    exit 1
                fi
                if [ $(curl -s --head ${varPicNameL}_${j}.jpg | head -n1 | cut -d ' ' -f2) -eq 200 ]; then
                    wget -nv --directory-prefix="ROW_${j}" ${varPicNameL}_${j}.jpg
                fi
                if [ -f lastpicture ]; then
                    echo "" > lastpicture
                fi
            fi
        done
        varPicPre=${varPicNameS}
    done
fi

if [ -f lastpicture ]; then
    rm lastpicture
fi

exit 0