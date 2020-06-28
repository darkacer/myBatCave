class Student {
  int roll;

  public void setRoll(final int roll) {
    this.roll = roll;
  }

  public int getRoll() {
    return this.roll;
  }
}

public class FirstJavaProgram {
  public static void main(final String args[]) {

    final Student s1 = new Student();
    
    s1.setRoll(4);

    System.out.println("the roll number is " + s1.getRoll());

  }
}