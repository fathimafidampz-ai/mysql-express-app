#!/bin/bash

# ==========================================
# API Testing Script
# ==========================================
# This script tests all endpoints and displays results

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:3000"

# Function to test an endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -e "${BLUE}Testing:${NC} $name"
    echo -e "${YELLOW}URL:${NC} $url"
    
    # Make request and capture response code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    # Check if successful
    if [ "$response_code" -eq "$expected_code" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (Status: $response_code)"
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_code, Got: $response_code)"
    fi
    
    echo "----------------------------------------"
}

# Function to test and display JSON response
test_and_show() {
    local name=$1
    local url=$2
    
    echo -e "${BLUE}Testing:${NC} $name"
    echo -e "${YELLOW}URL:${NC} $url"
    
    # Make request and display formatted JSON
    response=$(curl -s "$url")
    
    # Check if response is valid
    if [ -n "$response" ]; then
        echo -e "${GREEN}Response:${NC}"
        echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
        echo -e "${GREEN}✓ SUCCESS${NC}"
    else
        echo -e "${RED}✗ FAILED - No response${NC}"
    fi
    
    echo "========================================"
    echo ""
}

# Clear screen
clear

echo "========================================"
echo "   MySQL Express API - Test Suite"
echo "========================================"
echo ""

# Wait for services to be ready
echo -e "${YELLOW}Checking if services are ready...${NC}"
sleep 2

# Test 1: Health Check
test_endpoint "Health Check" "$BASE_URL/health"

# Test 2: API Documentation
test_endpoint "API Documentation" "$BASE_URL/"

echo ""
echo "========================================"
echo "   Simple Queries (⭐)"
echo "========================================"
echo ""

# Test 3: Students by Grade
test_and_show "Get Students by Grade 10" "$BASE_URL/api/students/grade/10"

echo ""
echo "========================================"
echo "   JOIN Queries (⭐⭐)"
echo "========================================"
echo ""

# Test 4: Student Enrollments
test_and_show "Student Enrollments (INNER JOIN)" "$BASE_URL/api/students/1/enrollments"

# Test 5: All Students with Enrollments
test_endpoint "All Students with Enrollments (LEFT JOIN)" "$BASE_URL/api/students/all-with-enrollments"

echo ""
echo "========================================"
echo "   GROUP BY Queries (⭐⭐)"
echo "========================================"
echo ""

# Test 6: Students per Grade
test_and_show "Students Per Grade" "$BASE_URL/api/analytics/students-per-grade"

echo ""
echo "========================================"
echo "   HAVING Queries (⭐⭐⭐)"
echo "========================================"
echo ""

# Test 7: Popular Courses
test_and_show "Popular Courses (min 3 enrollments)" "$BASE_URL/api/courses/popular/3"

echo ""
echo "========================================"
echo "   Complex Queries (⭐⭐⭐⭐)"
echo "========================================"
echo ""

# Test 8: Student Performance
test_endpoint "Student Performance Analysis" "$BASE_URL/api/analytics/student-performance?minGPA=3.0"

# Test 9: Student Performance with Grade Filter
test_endpoint "Student Performance (Grade 10)" "$BASE_URL/api/analytics/student-performance?minGPA=3.0&grade=10"

# Test 10: Course Details
test_and_show "Course Details with Analytics" "$BASE_URL/api/analytics/course-details/1"

echo ""
echo "========================================"
echo "   Subquery Examples (⭐⭐⭐)"
echo "========================================"
echo ""

# Test 11: Students in Courses
test_endpoint "Students in Specific Courses" "$BASE_URL/api/students/in-courses?courseIds=1,2,3"

echo ""
echo "========================================"
echo "   Advanced Analytics (⭐⭐⭐⭐⭐)"
echo "========================================"
echo ""

# Test 12: Top Performers
test_and_show "Top Performers" "$BASE_URL/api/analytics/top-performers?minCourses=3&minGPA=3.5"

# Test 13: Department Analytics
test_and_show "Department Analytics" "$BASE_URL/api/analytics/departments"

echo ""
echo "========================================"
echo "   Test Summary"
echo "========================================"
echo ""
echo -e "${GREEN}All endpoint tests completed!${NC}"
echo ""
echo "To test manually, you can use:"
echo "  - Web browser for GET requests"
echo "  - curl command"
echo "  - Postman (import postman_collection.json)"
echo ""
echo "Example curl command:"
echo "  curl http://localhost:3000/api/students/grade/10"
echo ""
