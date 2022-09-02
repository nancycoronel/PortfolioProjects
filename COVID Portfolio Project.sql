Select *
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccination
--order by 3,4
--select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2

--looking at the Total Cases vs Total Deaths
--shows the likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid 

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with highest infection rate compared to Population

Select Location, MAX(total_cases) as HighestInfectionCount, population,	MAX((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 


--Showing continents with the Highest death count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/(SUM(new_cases))*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths 
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visulizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

--creating viz tables on my own (continents with the Highest death count per Population)

Create View MaxDeathPerPop as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
--order by TotalDeathCount desc

Select *
From MaxDeathPerPop
