package Generating_Dataset;

import java.io.*;
import java.nio.file.*;
import java.util.*;

import static Generating_Dataset.Crew.*;


public class Main {
    public static FileWriter fileWriter;
    public static BufferedWriter outputBuffer;
    public static ArrayList<User> users = new ArrayList<>();
    public static ArrayList<Film> films = new ArrayList<>();
    public static ArrayList<Crew> crews = new ArrayList<>();
    public static ArrayList<Season> seasons = new ArrayList<>();
    public static ArrayList<Review> reviews = new ArrayList<>();
    public static ArrayList<Award> awards = new ArrayList<>();

    public static void main(String[] args) {
        String[] tablesInsertionOrder = {"users", "film", "season", "crew", "acts", "produces", "writes", "firstrole", "review",
                "award", "interestedin", "trailerlink", "picturelink", "country"};

        makeUsers();
        makeFilms();
        makeCrews("actor");
        makeCrews("director");
        makeCrews("producer");
        makeCrews("writer");
        assignCrewsToFilms();
        makeReviews();
        makeAwards();
        makeInterests();
        makeTrailersAndPictures();
        makeCountries();

        insertUsers();
        insertFilms();
        insertSeasons();
        insertCrews();
        insertCrewsAssigning("acts");
        insertCrewsAssigning("firstrole");
        insertCrewsAssigning("produces");
        insertCrewsAssigning("writes");
        insertReviews();
        insertAwards();
        insertInterests();
        insertTrailersAndPics("trailerlink");
        insertTrailersAndPics("picturelink");
        insertCountries();

        try {
            fileWriter = new FileWriter("all_insertions_in_one.sql");
            outputBuffer = new BufferedWriter(fileWriter);
            for (int i = tablesInsertionOrder.length - 1; i >= 0; i--)
                // All previously saved data from all tables should be removed in reversed order of inserting tables, because of table dependencies.
                outputBuffer.write("delete from " + tablesInsertionOrder[i] + " where true;\n");
            outputBuffer.write("\n\n");

            for (String tableName : tablesInsertionOrder) {
                String fileContent = new String(Files.readAllBytes(Paths.get("insert_" + tableName + ".sql")));
                fileContent = fileContent + "\n\n\n";
                outputBuffer.write(fileContent);
            }
            outputBuffer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void makeUsers() {
        for (int i = 1; i <= 100; i++) {
            Random random = new Random();
            boolean typeRnd = random.nextBoolean();
            String name = "user" + i;
            String mail = makeRandomMail("user", i);
            String phone = makeRandomPhone();
            char type = typeRnd ? 'F': 'P';
            String pass = "";
            for (int j = 1; j <= 5; j++) {
                pass = pass.concat(String.valueOf(random.nextInt(10)));
                pass = pass.concat (String.valueOf ((char)(random.nextInt(26) + 65)));
            }
            users.add(new User(name, mail, pass, phone, type));
        }
    }

    private static String makeRandomPhone() {
        Random random = new Random();
        int preNum = random.nextInt(99) + 1;
        String phone = preNum < 10 ? "+0" + preNum : "+" + preNum;
        for (int j = 0; j < 10; j++)
            phone = phone.concat(String.valueOf(random.nextInt(10)));
        return phone;
    }

    private static String makeRandomMail(String entity, int i) {
        boolean boolRnd = new Random().nextBoolean();
        String mailDomain = boolRnd ? "gmail": "yahoo";
        return entity + i + "@" + mailDomain + ".com";
    }

    public static void makeFilms() {
        String[] langs = {"En", "Fr", "De", "Fa", "It", "Ar", "Tr", "Es"};
        String[] genres = {"Action", "Adventure", "Comedy", "Drama", "Crime", "Thriller", "Sci-Fi"};
        String[] ageRatings = {"G", "GP", "PG", "PG-13", "R", "NC-17", "X", "M"};

        // Producing info of 100 feature movies and series:
        for (int i = 1; i <= 100; i++) {
            Random random = new Random();
            boolean isSerial = random.nextBoolean();

            String name = isSerial ? "series" + i : "feature" + i;

            int fyr = random.nextInt(111) + 1900;
            int tyr = isSerial ? fyr + random.nextInt(10) + 1 : fyr + random.nextInt(4) + 1;

            int langIndex = random.nextInt(langs.length);
            String lang = langs[langIndex];

            int dur = isSerial ? random.nextInt(21) + 30 : random.nextInt(161) + 80;

            int genreIndex = random.nextInt(genres.length);
            String genre = genres[genreIndex];

            int budget = random.nextInt(300) + 80;

            String plotLink = "http://plots.db.com/plot" + i + ".txt";

            int revenue = random.nextBoolean() ?  random.nextInt(200): -1 * random.nextInt(200) ;
            revenue += budget;
            revenue = Math.max(revenue, 0);

            int ageRIndex = random.nextInt(ageRatings.length);
            String ageR = ageRatings[ageRIndex];

            Film newFilm = new Film(name, fyr, tyr, lang, dur, genre, budget, plotLink, revenue, ageR, isSerial);
            films.add(newFilm);
            if (isSerial) {
                int sNum = random.nextInt(5) + 1;
                for (int j = 1; j <= sNum; j++)
                    seasons.add(new Season(newFilm.getFid(), j, random.nextInt(16) + 5));
            }
        }
    }

    public static void makeCrews(String mainRole) {
        Random random = new Random();
        String[] allRoles = {"actor", "director", "writer", "producer"};
        HashMap<String, Boolean> roles = new HashMap<>(){};

        roles.put(mainRole, true);
        for (String role: allRoles) {
            if (!role.equals(mainRole))
                roles.put(role, random.nextBoolean());
        }

        String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
        for (int i = 1; i <= 100; i++) {
            boolean sexBool = random.nextBoolean();
            boolean isDead = random.nextBoolean();
            String name = mainRole + i;
            char sex = sexBool ? 'M' : 'F';
            String mail = makeRandomMail(mainRole, i);
            String phone = makeRandomPhone();
            int bYear = random.nextInt(106) + 1900;
            String bMonth = months[random.nextInt(months.length)];
            int bDay = random.nextInt(31) + 1;

            int dYear = isDead ? Math.min(bYear + random.nextInt(81) + 20, 2020) : -1;
            String dMonth = isDead ? "'" + months[random.nextInt(months.length)] + "'" : null; // The weird way of filling dMonth is because of its nullability while writing insert in sql.
            int dDay = isDead ? random.nextInt(31) + 1 : -1;

            Crew newCrew = new Crew(name, mail, phone, bYear, bMonth, bDay, dYear, dMonth, dDay, sex,
                    roles.get("director"), roles.get("producer") ,roles.get("actor") , roles.get("writer"));
            crews.add(newCrew);

            if (roles.get("director"))
                allDirectors.add(newCrew);
            if (roles.get("actor"))
                allActors.add(newCrew);
            if (roles.get("producer"))
                allProducers.add(newCrew);
            if (roles.get("writer"))
                allWriters.add(newCrew);
        }
    }

    private static void assignCrewsToFilms() {
        Random random = new Random();
        for (Film film: films) {
            //Assigning a director:
            int rndDirIndex = random.nextInt(allDirectors.size());
            film.setDirId(allDirectors.get(rndDirIndex).getCid());
            //Assigning from 1 to 4 writers:
            int writersCnt = random.nextInt(4) + 1;
            int[] rndWrtIndices = random.ints(0, allWriters.size()).distinct().limit(writersCnt).toArray();
            for (int rndWriterIndex: rndWrtIndices)
                film.addWriter(allWriters.get(rndWriterIndex));
            //Assigning from 1 to 3 producers:
            int producersCnt = random.nextInt(3) + 1;
            int[] rndProIndices = random.ints(0, allProducers.size()).distinct().limit(producersCnt).toArray();
            for (int rndProducerIndex: rndProIndices)
                film.addProducer(allProducers.get(rndProducerIndex));
            //Assigning from 2 to 15 producers:
            int actorsCnt = random.nextInt(9) + 2;
            int[] rndActIndices = random.ints(0, allActors.size()).distinct().limit(actorsCnt).toArray();
            for (int rndProducerIndex: rndActIndices)
                film.addActor(allActors.get(rndProducerIndex));
            //Assigning one or two first roles:
            int firstRoleCnt = random.nextInt(2) + 1;
            int[] firstRoleIndices = random.ints(0, film.getActors().size()).distinct().limit(firstRoleCnt).toArray();
            for (int i: firstRoleIndices)
                film.addFirstRole(film.getActors().get(i));
        }
    }

    public static void makeReviews() {
        Random random = new Random();
        for (User user : users) {
            int[] rndFilmIndices = random.ints(0, films.size()).distinct().limit(3).toArray();
            for (int rndFilmIndex : rndFilmIndices) {
                String descLink = "http://reviews.db.com/" + user.getEmailAddress() + "_" + films.get(rndFilmIndex).getName();
                reviews.add(new Review(user.getUid(), films.get(rndFilmIndex).getFid(), random.nextInt(11), descLink));
            }
        }
    }

    public static void makeAwards() {
        Random random = new Random();
        String[] awardTitles = {"Best First Role Actor", "Best First Role Actress", "Best Director", "Best Film", "Best Screenplay"};
        String[] festNames = {"Oscar", "Berlin", "Cannes", "Venice", "Busan", "Toronto"};

        int[] winnerFilmsIndices = random.ints(0, films.size()).distinct().limit((int) (0.2 * films.size())).toArray();
        for (int winnerFilmIndex: winnerFilmsIndices) {
            HashMap<String, Boolean> doesGetAward = new HashMap<>();

            Film winnerFilm = films.get(winnerFilmIndex);
            String fest = festNames[random.nextInt(festNames.length)];

            //Investigating if winnerFilm has either male or female actors:
            Crew firstMaleActor = null, firstFemaleActor = null;
            for (Crew actor: films.get(winnerFilmIndex).getFirstRoles()) {
                if (actor.getSex() == 'M')
                    firstMaleActor = actor;
                if (actor.getSex() == 'F')
                    firstFemaleActor = actor;
            }

            // Assigning award titles to films
            doesGetAward.put("Best First Role Actor", firstMaleActor != null && random.nextBoolean());
            doesGetAward.put("Best First Role Actress", firstFemaleActor != null && random.nextBoolean());
            for (String awardTitle: awardTitles) {
                if (!awardTitle.equals("Best First Role Actor") && !awardTitle.equals("Best First Role Actress"))
                    doesGetAward.put(awardTitle, random.nextBoolean());
            }

            for (HashMap.Entry<String, Boolean> entry: doesGetAward.entrySet()) {
                if (entry.getValue()) {
                    if (entry.getKey().equals("Best First Role Actor"))
                        awards.add(new Award(entry.getKey(), fest, winnerFilm.getTyr(), winnerFilm.getFid(), firstMaleActor.getCid()));
                    if (entry.getKey().equals("Best First Role Actress"))
                        awards.add(new Award(entry.getKey(), fest, winnerFilm.getTyr(), winnerFilm.getFid(), firstFemaleActor.getCid()));
                    if (entry.getKey().equals("Best Director"))
                        awards.add(new Award(entry.getKey(), fest, winnerFilm.getTyr(), winnerFilm.getFid(), winnerFilm.getDirId()));
                    if (entry.getKey().equals("Best Screenplay"))
                        for (Crew writer: winnerFilm.getWriters())
                            awards.add(new Award(entry.getKey(), fest, winnerFilm.getTyr(), winnerFilm.getFid(), writer.getCid()));
                    if (entry.getKey().equals("Best Film"))
                        for (Crew producer: winnerFilm.getProducers())
                            awards.add(new Award(entry.getKey(), fest, winnerFilm.getTyr(), winnerFilm.getFid(), producer.getCid()));
                }
            }
        }
    }

    public static void makeInterests() {
        Random random = new Random();
        for (User user: users) {
            boolean hasAnyInterest = random.nextBoolean();
            if (!hasAnyInterest)
                continue;
            int interestsCnt = random.nextInt(5) + 1;
            int[] interestedFilmsIndices = random.ints(0, films.size()).distinct().limit(interestsCnt).toArray();
            for (int i: interestedFilmsIndices)
                user.addInterestFilm(films.get(i));
        }
    }

    public static void makeTrailersAndPictures() {
        Random random = new Random();
        for (Film film: films) {
            int trailersCnt = random.nextInt(2) + 1;
            int picturesCnt = random.nextInt(4) + 1;
            for (int i = 1; i <= trailersCnt; i++)
                film.addTrailerLink("http://trailers.db.com/" + film.getName() + "_trlr" + i);
            for (int i = 1; i <= picturesCnt; i++)
                film.addPictureLink("http://pictures.db.com/" + film.getName() + "_pic" + i);
        }
    }

    public static void makeCountries() {
        String[] countries = {"US", "GB", "IR", "FR", "IT", "DE", "JP", "KR", "TR", "CN"};
        Random random = new Random();
        for (Film film: films) {
            int countriesCnt = random.nextInt(3) + 1;
            int[] countryIndices = random.ints(0, countries.length).distinct().limit(countriesCnt).toArray();
            for (int i: countryIndices)
                film.addCountry(countries[i]);
        }
    }


    //********************************************************************************
    //********************************************************************************
    //********************************************************************************
    //*************************** Inserts ********************************************
    //********************************************************************************
    //********************************************************************************
    //********************************************************************************

    public static void insertUsers() {
        try {
            fileWriter = new FileWriter("insert_users.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (User user: users) {
            String fieldValues = String.format("('%s', '%s', '%s', '%s', '%s', '%c');\n",
                    user.getUid().toString(), user.getName(), user.getEmailAddress(), user.getPass(), user.getPhone(), user.getType());
            String insertIntoFormat = "insert into Users(uid, name, mail, pass, phone, utype) values";
            writeInsertInto(insertIntoFormat, fieldValues);
        }
    }

    public static void insertFilms() {
        try {
            fileWriter = new FileWriter("insert_film.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Film film: films) {
            String fieldValues = String.format("('%s', '%s', %d, %d, '%s', %d, '%s', %d, '%s', %d, '%s', %s);\n",
                    film.getFid().toString(), film.getName(), film.getFyr(), film.getTyr(), film.getLang(), film.getDur(),
                    film.getGenre(), film.getBudget(), film.getPlotLink(), film.getRevenue(), film.getAgeR(), film.isSerial());
            String insertIntoFormat = "insert into Film(fid, name, fyr, tyr, lang, dur, genre, budg, plotl, reven, ager, isser) values";
            writeInsertInto(insertIntoFormat, fieldValues);
        }

    }

    public static void insertSeasons() {
        try {
            fileWriter = new FileWriter("insert_season.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Season season: seasons) {
            String fieldValues = String.format("('%s', %d, %d);\n", season.getFid().toString(), season.getsNum(), season.getEpCnt());
            String insertIntoFormat = "insert into Season(fid, snum, epcnt) values";
            writeInsertInto(insertIntoFormat, fieldValues);
        }

    }

    public static void insertCrews() {
        try {
            fileWriter = new FileWriter("insert_crew.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Crew crew: crews) {
            String dYearStr = crew.getdYear() == -1 ? "null" : String.valueOf(crew.getdYear());
            String dDayStr = crew.getdDay() == -1 ? "null" : String.valueOf(crew.getdDay());

            String fieldValues = String.format("('%s', '%s', '%s', '%s', %d, '%s', %d, %s, %s, %s, '%c', %s, %s, %s, %s);\n",
                    crew.getCid().toString(), crew.getName(), crew.getEmailAddress(), crew.getPhone(), crew.getbYear(), crew.getbMonth(), crew.getbDay(),
                    dYearStr, crew.getdMonth(), dDayStr, crew.getSex(), crew.isDir(), crew.isPro(), crew.isAct(), crew.isWrt());
            String insertIntoFormat = "insert into Crew(cid, name, mail, phone, byear, bmon, bday, dyear, dmon, dday, sex, isdir, ispro, isact, iswrt) values";
            writeInsertInto(insertIntoFormat, fieldValues);
        }

    }

    private static void insertCrewsAssigning(String roleTableName) {
        try {
            fileWriter = new FileWriter("insert_" + roleTableName + ".sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Film film: films) {
            if (roleTableName.equals("acts")) {
                for (Crew actor: film.getActors()) {
                    String fieldValues = String.format("('%s', '%s');\n", actor.getCid().toString(), film.getFid().toString());
                    String insertIntoFormat = "insert into " + roleTableName + "(cid, fid) values";
                    writeInsertInto(insertIntoFormat, fieldValues);
                }
            }
            if (roleTableName.equals("firstrole")) {
                for (Crew actor: film.getFirstRoles()) {
                    String fieldValues = String.format("('%s', '%s');\n", actor.getCid().toString(), film.getFid().toString());
                    String insertIntoFormat = "insert into " + roleTableName + "(cid, fid) values";
                    writeInsertInto(insertIntoFormat, fieldValues);
                }
            }
            if (roleTableName.equals("produces")) {
                for (Crew producer: film.getProducers()) {
                    String fieldValues = String.format("('%s', '%s');\n", producer.getCid().toString(), film.getFid().toString());
                    String insertIntoFormat = "insert into " + roleTableName + "(cid, fid) values";
                    writeInsertInto(insertIntoFormat, fieldValues);
                }
            }
            if (roleTableName.equals("writes")) {
                for (Crew writer: film.getWriters()) {
                    String fieldValues = String.format("('%s', '%s');\n", writer.getCid().toString(), film.getFid().toString());
                    String insertIntoFormat = "insert into " + roleTableName + "(cid, fid) values";
                    writeInsertInto(insertIntoFormat, fieldValues);
                }
            }
        }
    }

    public static void insertReviews() {
        try {
            fileWriter = new FileWriter("insert_review.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Review review: reviews) {
            String fieldValues = String.format("('%s', '%s', %d, '%s');\n",
                    review.getUid().toString(), review.getFid().toString(), review.getRate(), review.getDescLink());
            String insertIntoFormat = "insert into Review(uid, fid, rate, descl) values";
            writeInsertInto(insertIntoFormat, fieldValues);
        }
    }

    public static void insertAwards() {
        try {
            fileWriter = new FileWriter("insert_award.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Award award: awards) {
            String fieldValues = String.format("('%s', '%s', %d, '%s', '%s');\n",
                    award.getTitle(), award.getFest(), award.getYear(), award.getFid().toString(), award.getCid().toString());
            String insertIntoFormat = "insert into Award(title, fest, year, fid, cid) values";
            writeInsertInto(insertIntoFormat, fieldValues);
        }
    }

    public static void insertInterests() {
        try {
            fileWriter = new FileWriter("insert_interestedin.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (User user: users) {
            for (Film film: user.getInterestedFilms()) {
                String fieldValues = String.format("('%s', '%s');\n", user.getUid().toString(), film.getFid().toString());
                String insertIntoFormat = "insert into InterestedIn(uid, fid) values";
                writeInsertInto(insertIntoFormat, fieldValues);
            }
        }
    }

    public static void insertTrailersAndPics(String tableName) {
        try {
            fileWriter = new FileWriter("insert_" + tableName + ".sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Film film: films) {
            if (tableName.equals("trailerlink")) {
                for (String trail: film.getTrailerLinks()) {
                    String fieldValues = String.format("('%s', '%s');\n", film.getFid().toString(), trail);
                    String insertIntoFormat = "insert into " + tableName + "(fid, link) values";
                    writeInsertInto(insertIntoFormat, fieldValues);
                }
            }
            if (tableName.equals("picturelink")) {
                for (String pic: film.getPictureLinks()) {
                    String fieldValues = String.format("('%s', '%s');\n", film.getFid().toString(), pic);
                    String insertIntoFormat = "insert into " + tableName + "(fid, link) values";
                    writeInsertInto(insertIntoFormat, fieldValues);
                }
            }
        }
    }

    public static void insertCountries() {
        try {
            fileWriter = new FileWriter("insert_country.sql");
            outputBuffer = new BufferedWriter(fileWriter);
        } catch (IOException e) {
            e.printStackTrace();
        }

        for (Film film: films) {
            for (String country: film.getCountries()) {
                String fieldValues = String.format("('%s', '%s');\n", film.getFid().toString(), country);
                String insertIntoFormat = "insert into Country(fid, name) values";
                writeInsertInto(insertIntoFormat, fieldValues);
            }
        }
    }

    private static void writeInsertInto(String insertIntoFormat, String fieldValues) {
        try {
            outputBuffer.write(insertIntoFormat);
            outputBuffer.write(fieldValues);
            outputBuffer.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
