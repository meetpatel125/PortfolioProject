Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--where continent is not null
--order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

--Select Location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathsPercentage
--From PortfolioProject..CovidDeaths
--where Location like'%india%'
--where continent is not null
--order by 1,2

--Looking at Total Cases vs Population
--Shows that percentage of pupulation got covid

--Select Location, date, population,total_cases, (total_cases/population)*100 as DeathsPercentage
--From PortfolioProject..CovidDeaths
--where Location like'%india%'
--order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where Location like'%india%'
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where Location like'%india%'
where continent is not null
Group by Location, Population
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where Location like'%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_deaths as int)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like'%india%'
where continent is not null
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, ROllingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (ROllingPeopleVaccinated/Population)*100 
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select * 
From PercentPopulationVaccinated