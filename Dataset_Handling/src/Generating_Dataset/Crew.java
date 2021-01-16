package Generating_Dataset;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class Crew {
    public static ArrayList<Crew> allActors = new ArrayList<>();
    public static ArrayList<Crew> allDirectors = new ArrayList<>();
    public static ArrayList<Crew> allProducers = new ArrayList<>();
    public static ArrayList<Crew> allWriters = new ArrayList<>();

    private UUID cid;
    private String name;
    private String emailAddress;
    private String phone;
    private int bYear;
    private String bMonth;
    private int bDay;
    private int dYear;
    private String dMonth;
    private int dDay;
    private char sex;
    private boolean isDir;
    private boolean isPro;
    private boolean isAct;
    private boolean isWrt;

    public Crew(String name, String emailAddress, String phone, int bYear, String bMonth, int bDay, int dYear, String dMonth, int dDay, char sex, boolean isDir, boolean isPro, boolean isAct, boolean isWrt) {
        // Generating cid from name and email:
        String tempID = name.concat(emailAddress);
        byte[] serializedID = tempID.getBytes(StandardCharsets.UTF_8);
        cid = UUID.nameUUIDFromBytes(serializedID);

        this.name = name;
        this.emailAddress = emailAddress;
        this.phone = phone;
        this.bYear = bYear;
        this.bMonth = bMonth;
        this.bDay = bDay;
        this.dYear = dYear;
        this.dMonth = dMonth;
        this.dDay = dDay;
        this.sex = sex;
        this.isDir = isDir;
        this.isPro = isPro;
        this.isAct = isAct;
        this.isWrt = isWrt;
    }

    public char getSex() {
        return sex;
    }

    public boolean isDir() {
        return isDir;
    }

    public boolean isPro() {
        return isPro;
    }

    public boolean isAct() {
        return isAct;
    }

    public boolean isWrt() {
        return isWrt;
    }

    public UUID getCid() {
        return cid;
    }

    public String getName() {
        return name;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

    public String getPhone() {
        return phone;
    }

    public int getbYear() {
        return bYear;
    }

    public String getbMonth() {
        return bMonth;
    }

    public int getbDay() {
        return bDay;
    }

    public int getdYear() {
        return dYear;
    }

    public String getdMonth() {
        return dMonth;
    }

    public int getdDay() {
        return dDay;
    }
}