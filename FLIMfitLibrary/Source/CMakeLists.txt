#=========================================================================
#
# Copyright (C) 2013 Imperial College London.
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# This software tool was developed with support from the UK 
# Engineering and Physical Sciences Council 
# through  a studentship from the Institute of Chemical Biology 
# and The Wellcome Trust through a grant entitled 
# "The Open Microscopy Environment: Image Informatics for Biological Sciences" (Ref: 095931).
#
# Author : Sean Warren
#
#=========================================================================

cmake_minimum_required(VERSION 2.8.10)

project(FLIMfit)

# Include the BOOST header files
#===================================================
FIND_PACKAGE(Boost)
if(Boost_FOUND)
    INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIR})
endif()
include_directories( "../Boost" )

# Enable OpenMP support, disable for XCode
#===================================================
if(APPLE AND ${CMAKE_GENERATOR} MATCHES "Xcode")
   set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
   set(CMAKE_XCODE_ATTRIBUTE_ENABLE_OPENMP_SUPPORT "YES")
else(APPLE AND ${CMAKE_GENERATOR} MATCHES "Xcode")
   find_package("OpenMP")
   if (OPENMP_FOUND)
      option(USE_OMP "Use OpenMP" ON)
      if (USE_OMP)
         set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS} -DUSE_OMP")
         message("Using OpenMP")
      endif()
   endif()
endif()

#find_package(HDF5)
#include_directories (${HDF5_INCLUDE_DIRS})

include_directories( ${LEVMAR_INCLUDE_DIRS} )



# Set the source and header files
#===================================================
set(SOURCE
   FitStatus.cpp
   IRFConvolution.cpp
   ModelADA.cpp
   FLIMGlobalAnalysis.cpp
   FLIMGlobalFitController.cpp
   FLIMGlobalFitController_ProcessRegion.cpp
   FLIMGlobalFitController_GetImageResults.cpp
   FLIMGlobalFitController_Model.cpp
   FLIMGlobalFitController_ADA.cpp
   FLIMData.cpp
   VariableProjector.cpp
   MaximumLikelihoodFitter.cpp
   AbstractFitter.cpp
   tinythread.cpp
   lmstr.cpp
   lmstx.cpp
   lmdif.cpp
   fdjac2.cpp
   cminpack_support.cpp
   util.cpp
)

set(HEADERS   
   FitStatus.h
   IRFConvolution.h
   ModelADA.h
   FLIMGlobalAnalysis.h
   FLIMGlobalFitController.h
   FLIMData.h
   ModelADA.h
   VariableProjector.h
   AbstractFitter.h
   MaximumLikelihoodFitter.h
   tinythread.h
   FlagDefinitions.h
   cminpack.h
   util.h
   TrimmedMean.h
   omp_stub.h
   ImageStats.h
   ConcurrencyAnalysis.h
)

# Add _32/_64 appendix to library
#===================================================
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
   set( LIB_NAME "FLIMGlobalAnalysis_64" )
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
   set( LIB_NAME "FLIMGlobalAnalysis_32" ) 
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUT_DIR})
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG   ${OUT_DIR})
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${OUT_DIR})
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${OUT_DIR})
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${OUT_DIR})
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${OUT_DIR})
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${OUT_DIR})


# Copy header to output directory
#===================================================
#file(COPY  ${CMAKE_SOURCE_DIR}/Source/FLIMGlobalAnalysis.h DESTINATION ${OUT_DIR})
#file(COPY  ${CMAKE_SOURCE_DIR}/Source/FlagDefinitions.h DESTINATION ${OUT_DIR})

# Include optimisation flags in Visual Studio
#===================================================
if(MSVC)
   set(PLATFORM_FLAGS_ALL "/Oi /fp:fast")
   set(PLATFORM_FLAGS_RELEASE "/Ox /Ot /Ob2")
   set(PLATFORM_FLAGS_RELWITHDEBINFO "/Ox /Ot /Ob2")
   set(PLATFORM_FLAGS_DEBUG "/ZI")
   add_definitions(-D_CRT_SECURE_NO_WARNINGS)
   add_definitions(-D_MSVC)

   if(CMAKE_VS_PLATFORM_TOOLSET MATCHES "v110")
	 message("Warning: When using VS2012 make sure you select the v110_xp toolchain to allow use on WinXP")
   endif(CMAKE_VS_PLATFORM_TOOLSET MATCHES "v110")
endif(MSVC)

if(UNIX)
   set(PLATFORM_FLAGS_ALL "-msse3 -std=c++11")
   set(PLATFORM_FLAGS_RELEASE "-O3 -ffast-math -ftree-vectorize")
   set(PLATFORM_FLAGS_DEBUG "")
endif(UNIX)

# Add platform specific flags
#===================================================
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PLATFORM_FLAGS_ALL}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${PLATFORM_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${PLATFORM_FLAGS_DEBUG}")


add_definitions(-DBOOST_DATE_TIME_NO_LIB)

# Make library
#===================================================
set(STATIC_NAME "${LIB_NAME}_lib")
add_library(${STATIC_NAME} STATIC ${SOURCE} ${HEADERS} )

add_library(${LIB_NAME} SHARED FLIMGlobalAnalysis.h FLIMGlobalAnalysis.cpp)


target_link_libraries(${LIB_NAME} ${STATIC_NAME} levmar)



# Make sure we don't have 'lib' prefix on UNIX
#===================================================
set_target_properties(${LIB_NAME} PROPERTIES PREFIX "")

get_target_property(LIB_LOCATION ${LIB_NAME} LOCATION)
add_custom_command(TARGET ${LIB_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${LIB_LOCATION} ${OUT_DIR}
                                                 COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/Source/FLIMGlobalAnalysis.h" ${OUT_DIR}
                                                 COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/Source/FlagDefinitions.h" ${OUT_DIR})

set( FGP_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR} CACHE STRING "Include dir for GlobalProcessing." FORCE )
set( FGP_LIB ${STATIC_NAME} CACHE STRING "Include dir for GlobalProcessing." FORCE )
set( FGP_LIB_DIR ${OUT_DIR} CACHE STRING "Include dir for GlobalProcessing." FORCE )

