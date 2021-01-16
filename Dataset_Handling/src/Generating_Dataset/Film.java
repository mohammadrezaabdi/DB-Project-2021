package Generating_Dataset;

import java.nio.charset.StandardCharsets;
import java.util.*;

public class Film {
    private UUID fid;
    private String name;
    private int fyr;
    private int tyr;
    private String lang;
    private int dur;
    private String genre;
    private int budget;
    private String plotLink;
    private int revenue;
    private String ageR;
//    public Timestamp timeStamp;
    private boolean isSerial;
    private UUID dirId;

    // Relations between film and crew:
    private ArrayList<Crew> firstRoles = new ArrayList<>();
    private ArrayList<Crew> actors = new ArrayList<>();
    private ArrayList<Crew> writers = new ArrayList<>();
    private ArrayList<Crew> producers = new ArrayList<>();

    // Multi-Value Attributes:
    private ArrayList<String> trailerLinks = new ArrayList<>();
    private ArrayList<String> pictureLinks = new ArrayList<>();
    private ArrayList<String> countries = new ArrayList<>();


    public Film(String name, int fyr, int tyr, String lang, int dur, String genre, int budget, String plotLink, int revenue, String ageR, boolean isSerial) {
        // Generating fid from name, fyr, and tyr:
        String tempID = (name.concat(String.valueOf(fyr))).concat(String.valueOf(tyr));
        byte[] serializedID = tempID.getBytes(StandardCharsets.UTF_8);
        fid = UUID.nameUUIDFromBytes(serializedID);

        this.name = name;
        this.fyr = fyr;
        this.tyr = tyr;
        this.lang = lang;
        this.dur = dur;
        this.genre = genre;
        this.budget = budget;
        this.plotLink = plotLink;
        this.revenue = revenue;
        this.ageR = ageR;
        this.isSerial = isSerial;
    }

    public void addFirstRole(Crew actor) {
        firstRoles.add(actor);
    }

    public void addActor(Crew actor) {
        actors.add(actor);
    }

    public void addWriter(Crew writer) {
        writers.add(writer);
    }

    public void addProducer(Crew producer) {
        producers.add(producer);
    }

    public void addTrailerLink(String trailerL) {
        this.trailerLinks.add(trailerL);
    }

    public void addPictureLink(String picL) {
        this.pictureLinks.add(picL);
    }

    public void addCountry(String country) {
        this.countries.add(country);
    }



    public UUID getFid() {
        return fid;
    }

    public String getName() {
        return name;
    }

    public int getFyr() {
        return fyr;
    }

    public int getTyr() {
        return tyr;
    }

    public String getLang() {
        return lang;
    }

    public int getDur() {
        return dur;
    }

    public String getGenre() {
        return genre;
    }

    public int getBudget() {
        return budget;
    }

    public String getPlotLink() {
        return plotLink;
    }

    public int getRevenue() {
        return revenue;
    }

    public String getAgeR() {
        return ageR;
    }

    public boolean isSerial() {
        return isSerial;
    }

    public UUID getDirId() {
        return dirId;
    }

    public ArrayList<Crew> getFirstRoles() {
        return firstRoles;
    }

    public ArrayList<Crew> getActors() {
        return actors;
    }

    public ArrayList<Crew> getWriters() {
        return writers;
    }

    public ArrayList<Crew> getProducers() {
        return producers;
    }

    public ArrayList<String> getTrailerLinks() {
        return trailerLinks;
    }

    public ArrayList<String> getPictureLinks() {
        return pictureLinks;
    }

    public ArrayList<String> getCountries() {
        return countries;
    }

    //Setters:

    public void setDirId(UUID dirId) {
        this.dirId = dirId;
    }
}