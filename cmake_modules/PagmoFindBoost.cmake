# Run a first pass for finding the headers only,
# and establishing the Boost version.
set(_PAGMO_BOOST_MINIMUM_VERSION 1.60.0)
find_package(Boost ${_PAGMO_BOOST_MINIMUM_VERSION} QUIET REQUIRED)

set(_PAGMO_REQUIRED_BOOST_LIBS serialization)

# Add the unit test framework, if needed.
if(_PAGMO_FIND_BOOST_UNIT_TEST_FRAMEWORK)
    list(APPEND _PAGMO_REQUIRED_BOOST_LIBS unit_test_framework)
endif()

if(_PAGMO_FIND_BOOST_PYTHON)
    # NOTE: since Boost 1.67, the naming of the Boost.Python library has changed to include the
    # major and minor python version as a suffix. See the release notes:
    # https://www.boost.org/users/history/version_1_67_0.html
    if(${Boost_MAJOR_VERSION} GREATER 1 OR (${Boost_MAJOR_VERSION} EQUAL 1 AND ${Boost_MINOR_VERSION} GREATER 66))
        list(APPEND _PAGMO_REQUIRED_BOOST_LIBS "python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}")
    else()
        if(${PYTHON_VERSION_MAJOR} EQUAL 2)
            list(APPEND _PAGMO_REQUIRED_BOOST_LIBS python)
        else()
            list(APPEND _PAGMO_REQUIRED_BOOST_LIBS python3)
        endif()
    endif()
endif()
message(STATUS "Required Boost libraries: ${_PAGMO_REQUIRED_BOOST_LIBS}")
find_package(Boost ${_PAGMO_BOOST_MINIMUM_VERSION} REQUIRED COMPONENTS "${_PAGMO_REQUIRED_BOOST_LIBS}")
if(NOT Boost_FOUND)
    message(FATAL_ERROR "Not all requested Boost components were found, exiting.")
endif()
message(STATUS "Detected Boost version: ${Boost_VERSION}")
message(STATUS "Boost include dirs: ${Boost_INCLUDE_DIRS}")
# Might need to recreate targets if they are missing (e.g., older CMake versions).
if(NOT TARGET Boost::boost)
    message(STATUS "The 'Boost::boost' target is missing, creating it.")
    add_library(Boost::boost INTERFACE IMPORTED)
    set_target_properties(Boost::boost PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
endif()
if(NOT TARGET Boost::disable_autolinking)
    message(STATUS "The 'Boost::disable_autolinking' target is missing, creating it.")
    add_library(Boost::disable_autolinking INTERFACE IMPORTED)
    if(WIN32)
        set_target_properties(Boost::disable_autolinking PROPERTIES INTERFACE_COMPILE_DEFINITIONS "BOOST_ALL_NO_LIB")
    endif()
endif()
foreach(_PAGMO_BOOST_COMPONENT ${_PAGMO_REQUIRED_BOOST_LIBS})
    if(NOT TARGET Boost::${_PAGMO_BOOST_COMPONENT})
        message(STATUS "The 'Boost::${_PAGMO_BOOST_COMPONENT}' imported target is missing, creating it.")
        string(TOUPPER ${_PAGMO_BOOST_COMPONENT} _PAGMO_BOOST_UPPER_COMPONENT)
        if(Boost_USE_STATIC_LIBS)
            add_library(Boost::${_PAGMO_BOOST_COMPONENT} STATIC IMPORTED)
        else()
            add_library(Boost::${_PAGMO_BOOST_COMPONENT} UNKNOWN IMPORTED)
        endif()
        set_target_properties(Boost::${_PAGMO_BOOST_COMPONENT} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${Boost_INCLUDE_DIRS}")
        set_target_properties(Boost::${_PAGMO_BOOST_COMPONENT} PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
            IMPORTED_LOCATION "${Boost_${_PAGMO_BOOST_UPPER_COMPONENT}_LIBRARY}")
    endif()
endforeach()

unset(_PAGMO_BOOST_MINIMUM_VERSION)
unset(_PAGMO_REQUIRED_BOOST_LIBS)
