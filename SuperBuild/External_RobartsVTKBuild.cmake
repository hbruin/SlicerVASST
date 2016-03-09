
set(proj RobartsVTKBuild)

# Set dependency list
set(${proj}_DEPENDS "")

# Include dependent projects if any
ExternalProject_Include_Dependencies(${proj} PROJECT_VAR proj)

if(${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})
  message(FATAL_ERROR "Enabling ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj} is not supported !")
endif()

# Sanity checks
if(DEFINED RobartsVTKBuild_DIR AND NOT EXISTS ${RobartsVTKBuild_DIR})
  message(FATAL_ERROR "RobartsVTKBuild_DIR variable is defined but corresponds to nonexistent directory")
endif()

if(NOT DEFINED ${proj}_DIR AND NOT ${CMAKE_PROJECT_NAME}_USE_SYSTEM_${proj})

  if(NOT DEFINED git_protocol)
    set(git_protocol "git")
  endif()

  ExternalProject_Add(${proj}
    ${${proj}_EP_ARGS}
    SOURCE_DIR ${CMAKE_BINARY_DIR}/${proj}
    BINARY_DIR ${proj}-build
    #--Download step--------------
    GIT_REPOSITORY http://Git.imaging.robarts.ca/vasst/RobartsVTKBuild.git
    GIT_TAG "master"
    #--Configure step-------------
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_TESTING:BOOL=OFF
      -DSlicer_DIR:PATH=${Slicer_DIR}
      -DRobartsVTK_USE_REGISTRATION:BOOL=ON 
      -DRobartsVTK_Include_Outdated_Registration:BOOL=OFF 
      -DRobartsVTK_USE_COMMON:BOOL=ON 
      -DRobartsVTK_USE_CUDA:BOOL=ON 
      -DRobartsVTK_USE_CUDA_VISUALIZATION:BOOL=ON 
      -DRobartsVTK_USE_CUDA_ANALYTICS:BOOL=ON 
      -DRobartsVTK_WRAP_PYTHON:BOOL=ON 
      -DRobartsVTK_BUILD_EXAMPLES:BOOL=ON 
      -DBUILD_SHARED_LIBS:BOOL=ON 
      -DPYTHON_INCLUDE_DIRS:STRING=${PYTHON_INCLUDE_DIRS}
      -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
      -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
      -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS
      ${${proj}_DEPENDS}
    )
  set(${proj}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

else()
  ExternalProject_Add_Empty(${proj} DEPENDS ${${proj}_DEPENDS})
endif()

mark_as_superbuild(${proj}_DIR:PATH)
