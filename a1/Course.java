/*
  Name:         Matthew Smith
  MRU E-mail:   msmit474@mtroyal.ca
  Course:       COMP 3649

  Source File: Course.java
 */

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;

/*
 * This Class is used to hold the information of a course.
 *
 * It contains the name of the course and the list of the students ID numbers.
 */
public class Course implements Comparable<Course> {

    private String name;
    private int[] classList;
    private int fillLevel;
    private ArrayList<Course> adjList;
    private Set<Integer> IDs;

    public Course(String courseName) {
        name = courseName;
        classList = new int[30];
        fillLevel = 0;
        adjList = new ArrayList<Course>();
        IDs = new HashSet<Integer>();
    }

    public String getName() {
        return this.name;
    }

    public int getFillLevel() {
        return this.fillLevel;
    }

    /*
     * Takes a student ID number and adds it to the class list
     *
     * Doubles size of class list if more space is needed.
     */
    public void addStudent(int id) {

        // Check that there is room in class list
        if (this.fillLevel >= classList.length) {

            // increase size of class list
            int[] temp = new int[classList.length * 2];

            // copy old list
            for (int i = 0; i < classList.length; i++) {
                temp[i] = classList[i];
            }
            classList = temp;
        }

        // add student to class list
        classList[this.fillLevel] = id;
        this.fillLevel++;
    }

    /*
     * Takes the scanner for the course file as input
     *
     * Adds all the student ID's to the class list.
     */
    public boolean fill(Scanner courseReader) {
        boolean success = true;

        if (courseReader.hasNextInt()) {
            int number = courseReader.nextInt();

            // Check that line contains student ID
            // Student ID's are 9 digit numbers starting with 201
            if (number / 1000000 == 201) {

                // Add student to list
                this.addStudent(number);
                // Do next line.
                success = this.fill(courseReader);

                if(success) {
                    success = IDs.add(number);
                }
            }
            else {
                success = false;
            }
        }

        return success;
    }

    /*
     * This function returns true if two courses conflict
     *
     * Courses conflict if they share at least one student
     */
    public boolean conflict(Course other) {

        if (this != null && other != null && this != other) {

            // Check each ID to the other class list
            for (int i = 0; i < this.fillLevel; i++) {
                for (int j = 0; j < other.fillLevel; j++) {

                    // If there is a match the courses conflict
                    if (this.classList[i] == other.classList[j]) {
                        return true;
                    }
                }
            }
        }

        // No matching ID's were found
        return false;
    }

    /*
     * Check if a time slot conflicts
     */
    public boolean checkTimeSlot(ArrayList<Course>[] schedule,int timeSlot) {
        boolean conflict = false;

        for(int i = 0; i < schedule[timeSlot].size() && !conflict; i++) {
            conflict = this.conflict(schedule[timeSlot].get(i));
        }

        return !conflict;
    }

    /*
     * Creates a list of conflicting courses.
     *
     * index of adjacency list matches index of course list
     *
     * true if conflicting, false otherwise
     */
    public void makeList(ArrayList<Course> courses) {

        for(int i = 0; i < courses.size(); i++) {
            if(this.conflict(courses.get(i))) {
                this.adjList.add(courses.get(i));
            }
        }
    }

    /*
     * Compares the size of two adjacency lists
     *
     * is used to sort courses from most number of collisions to least number of collisions
     */
    @Override
    public int compareTo(Course other) {
        return (other.adjList.size() - this.adjList.size());
    }
}
