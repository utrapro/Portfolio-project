Select * 
from [Portfolio project]..Coviddeaths
order by 3,4
--Select * 
--from [Portfolio project]..Covidvaccination
--order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio project]..Coviddeaths
order by 1,2
--looking at total cases vs deaths
--shows the likelihood dying if you contract covid in your country

Select location, date, total_cases, new_cases, total_deaths, (CAST(total_deaths AS decimal)/total_cases)*100 as Deathpercentage
from [Portfolio project]..Coviddeaths
where location like 'India'
order by 2,6

--looking at total cases vs Population

Select location, population, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as Infectionrate
from [Portfolio project]..Coviddeaths
where location like 'India'
order by 3,7

--looking at countries with highest infection rate compared to population

Select location, population,MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population)*100) as Percentofpopulationinfected
from Coviddeaths
Group by Location,Population
order by Percentofpopulationinfected desc

--showing the countries with highest death count per population

--Let's break thing down by continent

Select location, population,MAX(cast(total_deaths as int)) as Highestdeathscount, MAX((total_deaths/population)*100) as Percentofpopulationdied
from Coviddeaths
WHERE CONTINENT is not null
Group by Location,Population
order by Percentofpopulationdied desc

--Let's break thing down by continent

Select location,MAX(cast(total_deaths as int)) as Totaldeathscount
from Coviddeaths
WHERE CONTINENT is null
Group by location
order by Totaldeathscount desc

--Global Numbers

Select sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths,
    CASE 
        WHEN Sum(new_cases)= 0 THEN NULL
        ELSE Sum(cast(new_deaths as int))/Sum(new_cases)*100  
    END as Deathpercentage
from Coviddeaths
WHERE CONTINENT is not null
--Group by date
order by 1,2 desc

--Looking at total population vs vaccination
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION,DEA.DATE) AS Rollingpeoplevaccinated
,
from [Portfolio project]..Coviddeaths dea
join [Portfolio project]..Covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
WITH POPVSVAC (Continent,location,date,population,New_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(DECIMAL,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION,DEA.DATE) AS Rollingpeoplevaccinated
--,(Rollingpeoplevaccianted/population)*100
from [Portfolio project]..Coviddeaths dea
join [Portfolio project]..Covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
sELECT *,(Rollingpeoplevaccinated/Population)*100
from POPVSVAC

--TEMP TABLE
Drop table if exists #qPercentagepopulationvacinated
CREATE table #qPercentagepopulationvacinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)
Insert into #qPercentagepopulationvacinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(DECIMAL,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION,DEA.DATE) AS Rollingpeoplevaccinated
--,(Rollingpeoplevaccianted/population)*100
from [Portfolio project]..Coviddeaths dea
join [Portfolio project]..Covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
sELECT *,(Rollingpeoplevaccinated/Population)*100
from #qPercentagepopulationvacinated

--CREATING VIEW FOR STORING DATA FOR LATER VISUALISATION
cREATE VIEW Percentagepeoplevaccianted as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(DECIMAL,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION,DEA.DATE) AS Rollingpeoplevaccinated
--,(Rollingpeoplevaccianted/population)*100
from [Portfolio project]..Coviddeaths dea
join [Portfolio project]..Covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * from Percentagepeoplevaccianted
