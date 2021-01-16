package Generating_Dataset;

import java.util.*;

public class Review {
    private UUID uid;
    private UUID fid;
    private int rate;
    private String descLink;

    public Review(UUID uid, UUID fid, int rate, String descLink) {
        this.uid = uid;
        this.fid = fid;
        this.rate = rate;
        this.descLink = descLink;
    }

    public UUID getUid() {
        return uid;
    }

    public UUID getFid() {
        return fid;
    }

    public int getRate() {
        return rate;
    }

    public String getDescLink() {
        return descLink;
    }
}
