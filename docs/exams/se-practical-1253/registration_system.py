# Package conceptually: Your_Full_Four_Part_Name
# University Electronic Registration System — exam Q5 sample
"""حل البند 5 — كود لمفاهيم نظام التسجيل الجامعي الإلكتروني."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List, Optional


@dataclass
class Course:
    course_code: str
    course_name: str
    credit_hours: int
    is_exceptional: bool = False

    def get_info(self) -> str:
        tag = " [استثنائي]" if self.is_exceptional else ""
        return f"{self.course_code} - {self.course_name} ({self.credit_hours}س){tag}"


@dataclass
class Student:
    student_id: str
    name: str
    password: str
    mobile: str
    modified_courses: List[Course] = field(default_factory=list)

    def login(self, password: str) -> bool:
        return self.password == password


@dataclass
class Administrator:
    admin_id: str
    name: str
    login_id: str
    password: str

    def login(self, login_id: str, password: str) -> bool:
        return self.login_id == login_id and self.password == password


@dataclass
class Registration:
    registration_id: str
    student: Student
    courses: List[Course] = field(default_factory=list)
    is_confirmed: bool = False
    status: str = "draft"

    def add_course(self, course: Course) -> str:
        if self.is_confirmed:
            return "لا يمكن التعديل بعد التأكيد"
        if any(c.course_code == course.course_code for c in self.courses):
            return "المقرر مسجّل مسبقاً"
        self.courses.append(course)
        self.student.modified_courses = list(self.courses)
        return f"تمت إضافة: {course.course_code}"

    def remove_course(self, course_code: str) -> str:
        if self.is_confirmed:
            return "لا يمكن التعديل بعد التأكيد"
        before = len(self.courses)
        self.courses = [c for c in self.courses if c.course_code != course_code]
        self.student.modified_courses = list(self.courses)
        return "تم الحذف" if len(self.courses) < before else "المقرر غير موجود"

    def save(self) -> str:
        self.status = "saved"
        return f"تم حفظ {len(self.courses)} مقرر/مقررات"

    def confirm(self) -> str:
        if not self.courses:
            return "لا توجد مقررات لتأكيدها"
        self.save()
        self.is_confirmed = True
        self.status = "confirmed"
        return "تم تأكيد قائمة المقررات بنجاح"


class RegistrationSystem:
    """Academic University Portal"""

    def __init__(self) -> None:
        self.portal_name = "Academic University Portal"
        self.available_courses: List[Course] = []
        self.students: Dict[str, Student] = {}
        self.admins: Dict[str, Administrator] = {}
        self.registrations: Dict[str, Registration] = {}

    def authenticate_student(self, student_id: str, password: str) -> Optional[Student]:
        student = self.students.get(student_id)
        if student and student.login(password):
            return student
        return None

    def authenticate_admin(self, login_id: str, password: str) -> Optional[Administrator]:
        for admin in self.admins.values():
            if admin.login(login_id, password):
                return admin
        return None

    def list_available_courses(self) -> List[Course]:
        return list(self.available_courses)

    def register_exceptional_course(
        self, admin: Administrator, student_id: str, course: Course
    ) -> str:
        if admin is None:
            return "صلاحية مشرف مطلوبة"
        reg = self.registrations.get(student_id)
        if reg is None:
            return "لا يوجد تسجيل للطالب"
        course.is_exceptional = True
        return reg.add_course(course)

    def view_student_courses(self, student_id: str) -> List[str]:
        reg = self.registrations.get(student_id)
        if not reg:
            return []
        return [c.get_info() for c in reg.courses]


def demo() -> None:
    system = RegistrationSystem()

    c1 = Course("0101", "مقدمة في الحاسوب", 3)
    c2 = Course("0102", "رياضيات عامة", 3)
    system.available_courses.extend([c1, c2])

    student = Student("123456789", "دارس تجريبي", "pass123", "0599000000")
    system.students[student.student_id] = student
    system.registrations[student.student_id] = Registration("R1", student)

    admin = Administrator("A1", "مشرف النظام", "admin", "admin@123")
    system.admins[admin.admin_id] = admin

    user = system.authenticate_student("123456789", "pass123")
    print("Login:", "نجاح" if user else "فشل")

    reg = system.registrations[student.student_id]
    print("Available:", [c.get_info() for c in system.list_available_courses()])
    print(reg.add_course(c1))
    print(reg.add_course(c2))
    print(reg.remove_course("0102"))
    print(reg.add_course(c2))
    print(reg.save())
    print(reg.confirm())

    print("Admin view:", system.view_student_courses(student.student_id))
    exceptional = Course("0999", "مقرر استثنائي", 3)
    print(system.register_exceptional_course(admin, student.student_id, exceptional))


if __name__ == "__main__":
    demo()
