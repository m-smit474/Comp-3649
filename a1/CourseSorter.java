/*
  Name:         Matthew Smith
  MRU E-mail:   msmit474@mtroyal.ca
  Course:       COMP 3649

  Source File: CourseSorter.java
 */

import java.util.ArrayList;
import java.util.Collections;

/*
 * A class to sort the courses from most number of collisions to least number of collisions
 */
public class CourseSorter {
    private ArrayList<Course> courses;

    public CourseSorter(ArrayList<Course> courses) {
        this.courses = courses;
    }

    public ArrayList<Course> getSortedCourses() {
        Collections.sort(courses);
        return courses;
    }

}
