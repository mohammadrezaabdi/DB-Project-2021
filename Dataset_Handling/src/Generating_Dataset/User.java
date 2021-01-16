package Generating_Dataset;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class User {
    private char[] userTypes = {'F', 'P'};

    private UUID uid;
    private String name;
    private String emailAddress;
    private String pass;
    private String phone;
    private char type;
//    private int eLimit;

    //Multi-Value Attributes:
    private ArrayList<Film> interestedFilms = new ArrayList<>();

    public User(String name, String emailAddress, String pass, String phone, char type/*, int eLimit*/) {
        // Generating uid from name and email:
        String tempID = name.concat(emailAddress);
        byte[] serializedID = tempID.getBytes(StandardCharsets.UTF_8);
        uid = UUID.nameUUIDFromBytes(serializedID);

        this.name = name;
        this.emailAddress = emailAddress;
        this.phone = phone;
        this.type = type;
        this.pass = pass;
//        this.eLimit = eLimit;
    }

    public void addInterestFilm(Film film) {
        this.interestedFilms.add(film);
    }

    public char[] getUserTypes() {
        return userTypes;
    }

    public UUID getUid() {
        return uid;
    }

    public String getName() {
        return name;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

    public String getPass() {
        return pass;
    }

    public String getPhone() {
        return phone;
    }

    public char getType() {
        return type;
    }

    public ArrayList<Film> getInterestedFilms() {
        return interestedFilms;
    }
}