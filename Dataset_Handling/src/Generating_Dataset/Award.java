package Generating_Dataset;

import java.util.*;

public class Award {
    private String title;
    private String fest;
    private int year;
    private UUID fid;
    private UUID cid;

    public Award(String title, String fest, int year, UUID fid, UUID cid) {
        this.title = title;
        this.fest = fest;
        this.year = year;
        this.fid = fid;
        this.cid = cid;
    }

    public String getTitle() {
        return title;
    }

    public String getFest() {
        return fest;
    }

    public int getYear() {
        return year;
    }

    public UUID getFid() {
        return fid;
    }

    public UUID getCid() {
        return cid;
    }
}
