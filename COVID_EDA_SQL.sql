use covid_data;
select*
from CovidDeaths
order by 3,4

--select*
--from covidVaccinations
--order by 3,4

--  Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths,population
From Covid_data..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Covid_data..CovidDeaths
where location like '%kenya%'
order by 1,2


-- Looking at Total Cases vs Population
-- What percentage of population has got Covid

Select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
From Covid_data..CovidDeaths
where location like '%kenya%'
order by 1,2

--Looking at  Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases)as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
From Covid_data..CovidDeaths
Group by location, population
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_data..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Breaking it down by Continent

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_data..CovidDeaths
where continent is not null
Group by Continent
Order by TotalDeathCount desc

-- Alternatively
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid_data..CovidDeaths
Where continent is  null
Group by location
Order by TotalDeathCount desc



-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as GlobalCases, SUM(cast(new_deaths as int))as GlobalDeaths
From Covid_data..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.population,dea.date, vac.new_vaccinations
From covid_data..CovidDeaths dea
Join covid_data..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Cumulative  vaccinations
Select dea.continent,dea.location, dea.population,dea.date, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From covid_data..CovidDeaths dea
Join covid_data..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopVsVac (Continent, Location,Population, Date, New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.population,dea.date, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From covid_data..CovidDeaths dea
Join covid_data..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric

)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From covid_data..CovidDeaths dea
Join covid_data..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.population,dea.date, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From covid_data..CovidDeaths dea
Join covid_data..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null