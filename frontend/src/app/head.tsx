import { getSiteTitle } from "@/shared/api";

export default function Head() {
  return (
    <>
      <title>{getSiteTitle()}</title>
      <meta content="width=device-width, initial-scale=1" name="viewport" />
      <meta name="description" content="Easy clip sharing with friends" />
      <link rel="icon" href="/favicon.ico" />
    </>
  );
}
