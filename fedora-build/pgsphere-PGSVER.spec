%global pgmajorversion 15
%global pginstdir /usr/pgsql-15
%global sname pgsphere

Summary:	R-Tree implementation using GiST for spherical objects
Name:		%{sname}%{pgmajorversion}
Version:	PGSVER
Release:	1%{?dist}
License:	BSD
Group:		Applications/Databases
Source0:	%{sname}-%{version}.tar.gz
URL:		https://github.com/pdowler/pgsphere
BuildRequires:	postgresql%{pgmajorversion}-devel
Requires:	postgresql%{pgmajorversion}-server
Requires:	healpix-c++
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
pgSphere is a server side module for PostgreSQL. It contains methods for
working with spherical coordinates and objects. It also supports indexing of
spherical objects.

%prep
%setup -q -n %{sname}-%{version}

%build
make PG_CONFIG=%{pginstdir}/bin/pg_config USE_PGXS=1 %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
DESTDIR=%{buildroot} PG_CONFIG=%{pginstdir}/bin/pg_config USE_PGXS=1 make install %{?_smp_mflags}

%clean
%{__rm} -rf %{buildroot}

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%changelog
* Wed Nov 29 2023 - Patrick Dowler <pdowler.cadc@gmail.com>
- build RPM from source

%files
%defattr(-,root,root,-)

