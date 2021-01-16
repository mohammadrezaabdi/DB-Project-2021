package Generating_Dataset;

import java.util.*;

public class Season {
    private UUID fid;
    private int sNum;
    private int epCnt;

    public Season(UUID fid, int sNum, int epCnt) {
        this.fid = fid;
        this.sNum = sNum;
        this.epCnt = epCnt;
    }

    public UUID getFid() {
        return fid;
    }

    public int getsNum() {
        return sNum;
    }

    public int getEpCnt() {
        return epCnt;
    }
}