/*
  Name:         Matthew Smith
  MRU E-mail:   msmit474@mtroyal.ca
  Course:       COMP 3649

  Source File: Room.java
 */

/*
 * A class to deal with rooms for exam scheduling
 */
public class Room {

    private String name;
    private int capacity;
    private int remaining;

    public Room(String roomName, int size) {
        name = roomName;
        capacity = size;
        remaining = capacity;
    }

}
